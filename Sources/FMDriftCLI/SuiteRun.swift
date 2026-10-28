import FMDriftKit
import Foundation

/// The work behind `run` and `record`: find and read suites, pick a provider, run, compare,
/// report.
struct SuiteRun {
    enum Mode {
        case run(Comparison)
        case record(directory: String)
    }

    var options: RunOptions
    var mode: Mode

    func execute(_ base: Context) async -> Int32 {
        var context = base
        if options.noColor { context.style = .plain }

        let files: [URL]
        do {
            files = try SuiteDiscovery.files(options.suites, context: context)
        } catch {
            context.error(SuiteDiscovery.noSuiteMessage)
            return ExitStatus.usage
        }
        guard let loaded = SuiteDiscovery.load(files, context: context) else { return ExitStatus.usage }
        guard checkSelectedCases(loaded.map(\.suite), context: context) else { return ExitStatus.usage }

        // One provider per suite: replay answers from that suite's snapshot.
        var providers: [String: any ModelProvider] = [:]
        if let replay = options.replay {
            for (url, suite) in loaded {
                switch SnapshotLookup.find(
                    at: replay, suite: suite.name, suiteCount: loaded.count, avoiding: nil, context: context)
                {
                case .found(_, let snapshot):
                    providers[suite.name] = ReplayProvider(snapshot: snapshot)
                case .missing:
                    context.error("no snapshot of suite `\(suite.name)` (\(context.display(url))) in \(replay)")
                    return ExitStatus.usage
                case .failed:
                    return ExitStatus.usage
                }
            }
        } else {
            let provider = context.makeProvider(options.timeout)
            if case .unavailable(let reason, let explanation) = await provider.availability() {
                if options.allowUnavailable {
                    context.notice("the on-device model is not available (\(reason)); no cases ran. \(explanation)")
                    return ExitStatus.clean
                }
                context.error("the on-device model is not available (\(reason)). \(explanation)")
                context.writeError(
                    "Run `fmdrift doctor` for details, or `fmdrift run --replay <snapshot>` to check recorded responses.\n"
                )
                return ExitStatus.usage
            }
            for (_, suite) in loaded { providers[suite.name] = provider }
        }

        var runs: [RunResult] = []
        var diffs: [SnapshotDiff] = []
        var failed = false
        for (url, suite) in loaded {
            guard let provider = providers[suite.name] else { continue }
            var result = await run(suite, provider: provider, context: context)
            if let replay = provider as? ReplayProvider {
                markChangedInputs(&result, recorded: replay.snapshot)
            }
            if !result.passed { failed = true }

            switch mode {
            case .record(let directory):
                let target = SnapshotStore.url(
                    in: context.url(for: directory), suite: suite.name, environment: result.environment)
                do {
                    try SnapshotStore.write(result, to: target)
                    context.writeError("Recorded \(context.display(target))\n")
                } catch {
                    context.error(error.description)
                    return ExitStatus.usage
                }
            case .run(let comparison):
                guard let path = comparison.path else { break }
                switch SnapshotLookup.find(
                    at: path,
                    suite: suite.name,
                    suiteCount: loaded.count,
                    avoiding: result.environment,
                    context: context
                ) {
                case .found(_, var baseline):
                    // With --case, compare only the cases that ran.
                    if !options.cases.isEmpty {
                        baseline.cases = baseline.cases.filter { options.cases.contains($0.id) }
                    }
                    let diff = SnapshotDiff(
                        baseline: baseline, current: result, latencyIncrease: comparison.latencyIncrease)
                    if diff.fails(under: comparison.policy) { failed = true }
                    diffs.append(diff)
                case .missing:
                    context.notice(
                        "no baseline snapshot of suite `\(suite.name)` (\(context.display(url))) in \(path); record one with `fmdrift record`"
                    )
                case .failed:
                    return ExitStatus.usage
                }
            }
            runs.append(result)
        }

        report(runs: runs, diffs: diffs, context: context)
        if let path = options.junit, !context.writeFile(JUnitReport.runs(runs), to: path) {
            return ExitStatus.usage
        }
        if let path = options.markdown {
            let text = (runs.map(MarkdownReport.run) + diffs.map(MarkdownReport.diff)).joined(separator: "\n")
            if !context.writeFile(text, to: path) { return ExitStatus.usage }
        }
        return failed ? ExitStatus.findings : ExitStatus.clean
    }

    func run(_ suite: Suite, provider: any ModelProvider, context: Context) async -> RunResult {
        let selection = options.cases.isEmpty ? nil : Set(options.cases)
        let override = options.repeatCount
        let replay = provider as? ReplayProvider
        let sampleCount: @Sendable (TestCase) -> Int = { testCase in
            if let replay { return replay.recordedCount(for: testCase.id) }
            return override ?? testCase.repeatCount
        }
        let progress = ProgressLine(context: context, suite: suite.name)
        var onProgress: (@Sendable (Runner.Progress) -> Void)?
        if context.showsProgress {
            onProgress = { progress.update($0) }
        }
        let result = await Runner(provider: provider).run(
            suite,
            cases: selection,
            sampleCount: sampleCount,
            progress: onProgress
        )
        progress.finish()
        return result
    }

    /// Notes cases whose prompt or options changed since the replayed snapshot was recorded.
    func markChangedInputs(_ result: inout RunResult, recorded: RunResult) {
        let fingerprints = Dictionary(
            recorded.cases.map { ($0.id, $0.fingerprint) }, uniquingKeysWith: { first, _ in first })
        for index in result.cases.indices {
            let id = result.cases[index].id
            guard let old = fingerprints[id] else {
                result.cases[index].notes.append("not in the snapshot; nothing to check")
                continue
            }
            if old != result.cases[index].fingerprint {
                result.cases[index].notes.append(
                    "the prompt, instructions, options or schema changed since the snapshot was recorded; the recorded responses answer the old input"
                )
            }
        }
    }

    func checkSelectedCases(_ suites: [Suite], context: Context) -> Bool {
        let known = Set(suites.flatMap { $0.cases.map(\.id) })
        for id in options.cases where !known.contains(id) {
            var message = "no case `\(id)` in the suites"
            if let guess = closest(id, in: known) { message += "; did you mean `\(guess)`?" }
            context.error(message)
            return false
        }
        return true
    }

    func closest(_ word: String, in candidates: Set<String>) -> String? {
        Spelling.suggestion(for: word, from: candidates.sorted())
    }

    func report(runs: [RunResult], diffs: [SnapshotDiff], context: Context) {
        if options.json {
            context.write(JSONEnvelope.text(runs: runs, diffs: diffs))
            return
        }
        var sections = runs.map { TerminalReport.run($0, style: context.style) }
        sections += diffs.map { TerminalReport.diff($0, style: context.style) }
        context.write(sections.joined(separator: "\n"))
    }
}

/// `--json` output of `run` and `record`.
enum JSONEnvelope {
    struct Body: Encodable {
        var fmdriftVersion: String
        var passed: Bool
        var runs: [RunResult]
        var diffs: [SnapshotDiff]
    }

    static func text(runs: [RunResult], diffs: [SnapshotDiff]) -> String {
        let passed = runs.allSatisfy(\.passed) && diffs.allSatisfy { $0.count(.regressed) == 0 }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        let body = Body(fmdriftVersion: FMDrift.version, passed: passed, runs: runs, diffs: diffs)
        let data = (try? encoder.encode(body)) ?? Data()
        return String(decoding: data, as: UTF8.self) + "\n"
    }
}

/// A one-line progress display on standard error.
final class ProgressLine: @unchecked Sendable {
    private let context: Context
    private let suite: String
    private let lock = NSLock()
    private var shown = false

    init(context: Context, suite: String) {
        self.context = context
        self.suite = suite
    }

    func update(_ progress: Runner.Progress) {
        let line =
            "[\(progress.completed)/\(progress.total)] \(TextSafety.terminal(suite)) · \(TextSafety.terminal(progress.caseID)) \(progress.sample)/\(progress.samples)"
        lock.withLock {
            shown = true
            context.writeError("\r\u{1B}[2K" + line)
        }
    }

    func finish() {
        lock.withLock {
            if shown { context.writeError("\r\u{1B}[2K") }
        }
    }
}
