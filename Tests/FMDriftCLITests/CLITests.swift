import FMDriftKit
import Foundation
import Testing

@testable import FMDriftCLI

/// Answers per case id, in order, with a configurable environment and availability.
struct FakeProvider: ModelProvider {
    var answers: [String: [Generation]]
    var environmentValue: RunEnvironment
    var availabilityValue: ModelAvailability = .available

    func availability() async -> ModelAvailability { availabilityValue }
    func environment() async -> RunEnvironment { environmentValue }
    func generate(_ request: GenerationRequest) async -> Generation {
        guard let list = answers[request.caseID], !list.isEmpty else {
            return .failed(.other, "no answer", latency: 0)
        }
        return list[request.sampleIndex % list.count]
    }

    static func environment(_ version: String, _ build: String) -> RunEnvironment {
        RunEnvironment(
            platform: "macOS",
            osVersion: version,
            osBuild: build,
            hardware: "Mac16,10",
            chip: "Apple M4",
            locale: "en_US",
            provider: "scripted",
            modelAvailability: "available",
            contextSize: 4096
        )
    }
}

/// Runs the command line in a temporary folder and captures what it prints.
final class Harness: @unchecked Sendable {
    let directory: URL
    private let lock = NSLock()
    private var out = ""
    private var err = ""
    var provider: FakeProvider

    init(provider: FakeProvider) throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("fmdrift-cli-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.provider = provider
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    var stdout: String { lock.withLock { out } }
    var stderr: String { lock.withLock { err } }

    func write(_ name: String, _ text: String) throws {
        let url = directory.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    func read(_ name: String) throws -> String {
        try String(contentsOf: directory.appendingPathComponent(name), encoding: .utf8)
    }

    func exists(_ name: String) -> Bool {
        FileManager.default.fileExists(atPath: directory.appendingPathComponent(name).path)
    }

    func run(_ arguments: String...) async -> Int32 {
        await run(arguments)
    }

    func run(_ arguments: [String]) async -> Int32 {
        lock.withLock {
            out = ""
            err = ""
        }
        let provider = self.provider
        let context = Context(
            write: { [self] text in lock.withLock { out += text } },
            writeError: { [self] text in lock.withLock { err += text } },
            currentDirectory: directory,
            environment: [:],
            showsProgress: false,
            style: .plain,
            makeProvider: { _ in provider }
        )
        return await CLI.main(arguments: arguments, context: context)
    }
}

let supportSuite = """
    name: support
    defaults:
      instructions: You help a support team.
    cases:
      - id: capital
        prompt: Capital of France?
        expect:
          - contains: Paris
      - id: sentiment
        prompt: "Classify: the app crashes."
        schema:
          type: object
          required: [sentiment]
          properties:
            sentiment: { type: string, enum: [positive, neutral, negative] }
        expect:
          - path: sentiment
            equals: negative
    """

let goodAnswers: [String: [Generation]] = [
    "capital": [Generation(text: "Paris", latency: 0.3, outputTokens: 1)],
    "sentiment": [Generation(text: #"{"sentiment":"negative"}"#, latency: 0.4, outputTokens: 6)],
]

let driftedAnswers: [String: [Generation]] = [
    "capital": [Generation(text: "It's Lyon.", latency: 0.35, outputTokens: 4)],
    "sentiment": [Generation(text: #"{"sentiment":"negative"}"#, latency: 0.4, outputTokens: 6)],
]

@Suite("Command line")
struct CLITests {
    func harness(_ answers: [String: [Generation]] = goodAnswers, version: String = "27.0.1", build: String = "26A434")
        throws -> Harness
    {
        let harness = try Harness(
            provider: FakeProvider(answers: answers, environmentValue: FakeProvider.environment(version, build))
        )
        try harness.write("fmdrift.yaml", supportSuite)
        return harness
    }

    @Test func helpAndVersion() async throws {
        let cli = try harness()
        #expect(await cli.run("--help") == 0)
        #expect(cli.stdout.contains("USAGE: fmdrift <subcommand>"))
        #expect(cli.stdout.contains("run (default)"))
        #expect(await cli.run("--version") == 0)
        #expect(cli.stdout == FMDrift.version + "\n")
        #expect(await cli.run("run", "--bogus") == 2)
        #expect(cli.stderr.contains("Unknown option '--bogus'"))
    }

    @Test func runsTheDefaultSuiteAndExitsCleanly() async throws {
        let cli = try harness()
        #expect(await cli.run() == 0)
        #expect(cli.stdout.contains("suite support · macOS 27.0.1 (26A434)"))
        #expect(cli.stdout.contains(" PASS  capital"))
        #expect(cli.stdout.contains("2 cases · 2 passed · 0 failed · 2 generations"))
    }

    @Test func exitsWithOneWhenACaseFails() async throws {
        let cli = try harness(driftedAnswers)
        #expect(await cli.run("run") == 1)
        #expect(cli.stdout.contains(" FAIL  capital"))
        #expect(cli.stdout.contains(#"✗ contains "Paris" — missing "Paris" in "It's Lyon.""#))
    }

    @Test func selectsCasesAndRepeats() async throws {
        let cli = try harness()
        #expect(await cli.run("run", "--case", "capital", "--repeat", "4") == 0)
        #expect(cli.stdout.contains("1 case · 1 passed · 0 failed · 4 generations"))
        #expect(await cli.run("run", "--case", "captial") == 2)
        #expect(cli.stderr == "error: no case `captial` in the suites; did you mean `capital`?\n")
    }

    @Test func printsJSONAndWritesReportFiles() async throws {
        let cli = try harness(driftedAnswers)
        #expect(await cli.run("run", "--json", "--junit", "out/junit.xml", "--markdown", "out/report.md") == 1)
        let json = try #require(JSONValue.parse(cli.stdout))
        #expect(json.value(at: ["passed"]) == .bool(false))
        #expect(json.value(at: ["runs", "0", "suite"]) == .string("support"))
        #expect(json.value(at: ["runs", "0", "cases", "0", "passed"]) == .bool(false))
        #expect(json.value(at: ["diffs"]) == .array([]))
        #expect(try cli.read("out/junit.xml").contains(#"<testsuite name="support" tests="2" failures="1""#))
        #expect(try cli.read("out/report.md").hasPrefix("## fmdrift: support"))
    }

    @Test func recordsAndComparesAcrossOSBuilds() async throws {
        let cli = try harness(goodAnswers, version: "26.4", build: "25E246")
        #expect(await cli.run("record") == 0)
        #expect(cli.stderr == "Recorded fmdrift-snapshots/support/macOS-26.4-25E246.json\n")
        let snapshot = try SnapshotStore.read(
            contentsOf: cli.directory.appendingPathComponent("fmdrift-snapshots/support/macOS-26.4-25E246.json")
        )
        #expect(snapshot.environment.osBuild == "25E246")

        // The OS updates and the model answers differently.
        cli.provider = FakeProvider(
            answers: driftedAnswers, environmentValue: FakeProvider.environment("27.0.1", "26A434"))
        #expect(await cli.run("record") == 1)
        #expect(cli.exists("fmdrift-snapshots/support/macOS-27.0.1-26A434.json"))

        // run --baseline with the folder picks the snapshot of the other OS build.
        #expect(await cli.run("run", "--baseline", "fmdrift-snapshots") == 1)
        #expect(cli.stdout.contains("baseline  macOS 26.4 (25E246)"))
        #expect(cli.stdout.contains(" REGRESSED  capital"))
        #expect(cli.stdout.contains("output: [-Paris-]{+It's Lyon.+}"))

        // diff reads the two files and needs no model.
        let base = "fmdrift-snapshots/support/macOS-26.4-25E246.json"
        let current = "fmdrift-snapshots/support/macOS-27.0.1-26A434.json"
        #expect(await cli.run("diff", base, current) == 1)
        #expect(cli.stdout.contains("1 regressed · 0 changed · 0 fixed · 1 unchanged"))
        #expect(await cli.run("diff", base, current, "--fail-on", "never") == 0)
        #expect(await cli.run("diff", base, base) == 0)
        #expect(await cli.run("diff", base, current, "--json") == 1)
        #expect(JSONValue.parse(cli.stdout)?.value(at: ["cases", "0", "status"]) == .string("regressed"))
        #expect(await cli.run("diff", base, current, "--markdown", "diff.md", "--all") == 1)
        #expect(cli.stdout.contains(" UNCHANGED  sentiment"))
        #expect(try cli.read("diff.md").contains("| ❌ regressed | capital |"))
    }

    @Test func failsOnChangesOrLatencyWhenAsked() async throws {
        let cli = try harness()
        #expect(await cli.run("record") == 0)
        cli.provider = FakeProvider(
            answers: [
                "capital": [Generation(text: "Paris.", latency: 0.9, outputTokens: 2)],
                "sentiment": [Generation(text: #"{"sentiment":"negative"}"#, latency: 0.4, outputTokens: 6)],
            ],
            environmentValue: FakeProvider.environment("27.1", "26B10")
        )
        #expect(await cli.run("run", "--baseline", "fmdrift-snapshots") == 0)
        #expect(cli.stdout.contains(" CHANGED    capital"))
        #expect(await cli.run("run", "--baseline", "fmdrift-snapshots", "--fail-on", "changed") == 1)
        #expect(await cli.run("run", "--baseline", "fmdrift-snapshots", "--max-latency-increase", "50%") == 1)
        #expect(cli.stdout.contains("slower than allowed"))
        #expect(await cli.run("run", "--max-latency-increase", "fast") == 2)
    }

    @Test func comparesOnlyTheSelectedCases() async throws {
        let cli = try harness(goodAnswers, version: "26.4", build: "25E246")
        #expect(await cli.run("record") == 0)
        #expect(await cli.run("run", "--baseline", "fmdrift-snapshots", "--case", "capital") == 0)
        #expect(!cli.stdout.contains("REMOVED"))
    }

    @Test func replaysRecordedResponsesWithoutAModel() async throws {
        let cli = try harness()
        #expect(await cli.run("record") == 0)
        cli.provider.availabilityValue = .unavailable(reason: "deviceNotEligible", explanation: "No model here.")
        #expect(await cli.run("run") == 2)
        #expect(await cli.run("run", "--replay", "fmdrift-snapshots") == 0)
        #expect(cli.stdout.contains("replayed responses"))

        // Tighten a check: the recorded answers are checked again.
        try cli.write(
            "fmdrift.yaml", supportSuite.replacingOccurrences(of: "contains: Paris", with: "contains: [Paris, France]"))
        #expect(await cli.run("run", "--replay", "fmdrift-snapshots/support/macOS-27.0.1-26A434.json") == 1)

        // Reword a prompt: the recorded answers no longer answer it, and the report says so.
        try cli.write(
            "fmdrift.yaml",
            supportSuite.replacingOccurrences(of: "Capital of France?", with: "What is the capital of France?"))
        #expect(await cli.run("run", "--replay", "fmdrift-snapshots") == 0)
        #expect(
            cli.stdout.contains(
                "note: the prompt, instructions, options or schema changed since the snapshot was recorded"))
    }

    @Test func handlesAMissingModel() async throws {
        let cli = try harness()
        cli.provider.availabilityValue = .unavailable(
            reason: "appleIntelligenceNotEnabled",
            explanation: "Turn on Apple Intelligence."
        )
        #expect(await cli.run("run") == 2)
        #expect(
            cli.stderr.hasPrefix(
                "error: the on-device model is not available (appleIntelligenceNotEnabled). Turn on Apple Intelligence.\n"
            ))
        #expect(await cli.run("run", "--allow-unavailable") == 0)
        #expect(
            cli.stderr.hasPrefix(
                "note: the on-device model is not available (appleIntelligenceNotEnabled); no cases ran."))
        #expect(await cli.run("doctor") == 1)
        #expect(cli.stdout.contains("On-device model not available (appleIntelligenceNotEnabled)"))
    }

    @Test func doctorDescribesTheMac() async throws {
        let cli = try harness()
        #expect(await cli.run("doctor") == 0)
        #expect(cli.stdout.contains("Snapshot name   macOS-27.0.1-26A434.json"))
        #expect(cli.stdout.contains("Context window  4096 tokens"))
        #expect(cli.stdout.contains("On-device model available"))
        #expect(await cli.run("doctor", "--json") == 0)
        #expect(JSONValue.parse(cli.stdout)?.value(at: ["osBuild"]) == .string("26A434"))
    }

    @Test func validatesSuitesWithoutAModel() async throws {
        let cli = try harness()
        try cli.write("suites/bad.yaml", "cases:\n  - id: a\n    prompt: p\n    expect:\n      - contans: x\n")
        try cli.write("suites/good.yml", supportSuite.replacingOccurrences(of: "name: support", with: "name: other"))
        #expect(await cli.run("validate") == 0)
        #expect(cli.stdout == "ok  fmdrift.yaml: suite `support`, 2 cases, 2 generations per run\n")
        #expect(await cli.run("validate", "suites") == 1)
        #expect(
            cli.stdout
                == "invalid  suites/bad.yaml:5: case `a` check: unknown key `contans`; did you mean `contains`?\nok  suites/good.yml: suite `other`, 2 cases, 2 generations per run\n"
        )
        #expect(await cli.run("run", "suites") == 2)
        #expect(cli.stderr.contains("suites/bad.yaml:5: case `a` check: unknown key `contans`"))
    }

    @Test func refusesTwoSuitesWithOneName() async throws {
        let cli = try harness()
        try cli.write("fmdrift/a.yaml", supportSuite)
        try cli.write("fmdrift/b.yaml", supportSuite)
        #expect(await cli.run("run", "fmdrift") == 2)
        #expect(cli.stderr.contains("are both named `support`"))
    }

    @Test func findsSuitesInTheFmdriftFolder() async throws {
        let cli = try Harness(
            provider: FakeProvider(answers: goodAnswers, environmentValue: FakeProvider.environment("27.0.1", "26A434"))
        )
        #expect(await cli.run("run") == 2)
        #expect(cli.stderr == "error: no suite found: pass a suite file, or create fmdrift.yaml with `fmdrift init`\n")
        try cli.write("fmdrift/support.yaml", supportSuite)
        #expect(await cli.run() == 0)
    }

    @Test func initWritesAStarterSuiteThatValidates() async throws {
        let cli = try Harness(
            provider: FakeProvider(answers: [:], environmentValue: FakeProvider.environment("27.0.1", "26A434")))
        #expect(await cli.run("init") == 0)
        #expect(cli.stdout.hasPrefix("Wrote fmdrift.yaml with two example cases."))
        #expect(await cli.run("init") == 2)
        #expect(cli.stderr == "error: fmdrift.yaml already exists; pass --force to replace it\n")
        #expect(await cli.run("init", "--force") == 0)
        #expect(await cli.run("validate") == 0)
        #expect(cli.stdout.contains("suite `starter`, 2 cases, 6 generations per run"))
    }

    @Test func escapesUntrustedTextInMessagesAndReports() async throws {
        let cli = try harness()
        try cli.write(
            "bad.yaml", "cases:\n  - id: a\n    prompt: p\n    expect:\n      - \"x\\e]52;c;ZXZpbA==\\a\": 1\n")
        #expect(await cli.run("validate", "bad.yaml") == 1)
        #expect(!cli.stdout.contains("\u{1B}"))
        #expect(cli.stdout.contains(#"\u{1B}]52;c;ZXZpbA==\u{7}"#))
        #expect(await cli.run("run", "bad.yaml") == 2)
        #expect(!cli.stderr.contains("\u{1B}"))

        // A snapshot is untrusted too: its OS fields reach the diff header.
        #expect(await cli.run("record") == 0)
        let path = "fmdrift-snapshots/support/macOS-27.0.1-26A434.json"
        var snapshot = try SnapshotStore.read(contentsOf: cli.directory.appendingPathComponent(path))
        snapshot.environment.osBuild = "26A434\u{1B}[2J\u{202E}"
        snapshot.environment.chip = "M\u{1B}]0;title\u{7}"
        try SnapshotStore.write(snapshot, to: cli.directory.appendingPathComponent("hostile.json"))
        #expect(await cli.run("diff", "hostile.json", path) == 0)
        #expect(!cli.stdout.contains("\u{1B}"))
        #expect(!cli.stdout.contains("\u{202E}"))
        #expect(cli.stdout.contains(#"macOS 27.0.1 (26A434\u{1B}[2J\u{202E})"#))
    }

    @Test func reportsUnreadableSnapshots() async throws {
        let cli = try harness()
        try cli.write("broken.json", "{}")
        #expect(await cli.run("diff", "broken.json", "missing.json") == 2)
        #expect(cli.stderr == "error: broken.json: has no `format`; is it an fmdrift snapshot?\n")
        #expect(await cli.run("run", "--baseline", "missing-folder") == 2)
        #expect(cli.stderr.contains("missing-folder does not exist"))
        #expect(await cli.run("record", "--replay", "x") == 2)
        #expect(await cli.run("run", "--replay", "x", "--repeat", "2") == 2)
    }
}
