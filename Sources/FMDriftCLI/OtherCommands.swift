import ArgumentParser
import FMDriftKit
import Foundation

struct DiffCommand: ContextCommand {
    static let configuration = CommandConfiguration(
        commandName: "diff",
        abstract: "Compare two snapshots, usually of the same suite on two OS builds.",
        discussion: "Needs no model: it reads the two files only."
    )

    @Argument(help: ArgumentHelp("The earlier snapshot.", valueName: "baseline"))
    var baseline: String

    @Argument(help: ArgumentHelp("The later snapshot.", valueName: "current"))
    var current: String

    @Option(help: ArgumentHelp("What fails the diff: regressed, changed or never.", valueName: "policy"))
    var failOn: FailOn = .regressed

    @Option(
        help: ArgumentHelp(
            "Mark a case slower when its median latency grows by more than this, e.g. 50%.", valueName: "share"))
    var maxLatencyIncrease: String?

    @Flag(help: "List unchanged cases too.")
    var all = false

    @Flag(help: "Print the diff as JSON instead of the report.")
    var json = false

    @Option(help: ArgumentHelp("Also write the diff as Markdown to this file.", valueName: "path"))
    var markdown: String?

    @Flag(help: "Do not color the report.")
    var noColor = false

    func validate() throws {
        _ = try LatencyShare.parse(maxLatencyIncrease)
    }

    func execute(_ base: Context) async -> Int32 {
        var context = base
        if noColor { context.style = .plain }
        var results: [RunResult] = []
        for path in [baseline, current] {
            do {
                results.append(try SnapshotStore.read(contentsOf: context.url(for: path)))
            } catch {
                context.error("\(path): \(error.message)")
                return ExitStatus.usage
            }
        }
        let increase = (try? LatencyShare.parse(maxLatencyIncrease)) ?? nil
        let diff = SnapshotDiff(baseline: results[0], current: results[1], latencyIncrease: increase)
        if json {
            context.write(JSONReport.diff(diff))
        } else {
            context.write(TerminalReport.diff(diff, style: context.style, showUnchanged: all))
        }
        if let markdown, !context.writeFile(MarkdownReport.diff(diff), to: markdown) {
            return ExitStatus.usage
        }
        return diff.fails(under: failOn.policy) ? ExitStatus.findings : ExitStatus.clean
    }
}

struct ValidateCommand: ContextCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Check suite files without running them. Exits with 1 when one is invalid.",
        discussion: "Needs no model: use it in CI on any runner."
    )

    @Argument(
        help: ArgumentHelp(
            "Suite files, or folders of them. Default: fmdrift.yaml, or the files in fmdrift/.", valueName: "suite"))
    var suites: [String] = []

    @Flag(help: "Do not color the output.")
    var noColor = false

    func execute(_ base: Context) async -> Int32 {
        var context = base
        if noColor { context.style = .plain }
        let files: [URL]
        do {
            files = try SuiteDiscovery.files(suites, context: context)
        } catch {
            context.error(SuiteDiscovery.noSuiteMessage)
            return ExitStatus.usage
        }
        var invalid = 0
        for url in files {
            do {
                let suite = try SuiteLoader.load(contentsOf: url)
                let generations = suite.cases.reduce(0) { $0 + $1.repeatCount }
                let summary = [
                    "suite `\(suite.name)`",
                    Format.count(suite.cases.count, "case", "cases"),
                    Format.count(generations, "generation per run", "generations per run"),
                ]
                context.write(
                    context.style.green("ok") + "  \(context.display(url)): \(summary.joined(separator: ", "))\n")
            } catch {
                invalid += 1
                context.write(
                    context.style.red("invalid")
                        + "  \(context.display(url))\(error.line.map { ":\($0)" } ?? ""): \(TextSafety.terminal(error.message))\n"
                )
            }
        }
        return invalid > 0 ? ExitStatus.findings : ExitStatus.clean
    }
}

struct InitCommand: ContextCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Write a starter suite, fmdrift.yaml, to the current folder."
    )

    @Option(help: ArgumentHelp("File to write.", valueName: "path"))
    var output: String = "fmdrift.yaml"

    @Flag(help: "Replace the file if it exists.")
    var force = false

    func execute(_ context: Context) async -> Int32 {
        let url = context.url(for: output)
        if FileManager.default.fileExists(atPath: url.path), !force {
            context.error("\(output) already exists; pass --force to replace it")
            return ExitStatus.usage
        }
        guard context.writeFile(StarterSuite.text, to: output) else { return ExitStatus.usage }
        context.write(
            """
            Wrote \(context.display(url)) with two example cases.

            Next:
              1. Put your own prompts and checks in it.
              2. fmdrift run        checks every response on this Mac's model
              3. fmdrift record     saves the results for this OS build in fmdrift-snapshots/

            After the next OS update: fmdrift run --baseline fmdrift-snapshots

            """
        )
        return ExitStatus.clean
    }
}

struct DoctorCommand: ContextCommand {
    static let configuration = CommandConfiguration(
        commandName: "doctor",
        abstract: "Show whether this Mac can run the on-device model, and which OS build it would record.",
        discussion: "Exits with 0 when the model is available and 1 when it is not."
    )

    @Flag(help: "Print the environment as JSON.")
    var json = false

    func execute(_ context: Context) async -> Int32 {
        let provider = context.makeProvider(120)
        let availability = await provider.availability()
        let environment = await provider.environment()
        if json {
            context.write(JSONOutput.text(environment))
        } else {
            let style = context.style
            var lines = [
                style.bold("fmdrift \(FMDrift.version)"),
                "  OS              \(TextSafety.terminal(environment.osLabel))",
                "  Snapshot name   \(environment.snapshotName).json",
            ]
            if !environment.chip.isEmpty { lines.append("  Chip            \(TextSafety.terminal(environment.chip))") }
            if !environment.hardware.isEmpty {
                lines.append("  Model           \(TextSafety.terminal(environment.hardware))")
            }
            if !environment.locale.isEmpty {
                lines.append("  Locale          \(TextSafety.terminal(environment.locale))")
            }
            if let size = environment.contextSize { lines.append("  Context window  \(size) tokens") }
            switch availability {
            case .available:
                lines.append("  On-device model " + style.green("available"))
            case .unavailable(let reason, let explanation):
                lines.append("  On-device model " + style.red("not available") + " (\(reason))")
                lines.append("                  \(explanation)")
                lines.append("                  " + style.dim(Advice.Source.availability.url))
            }
            context.write(lines.joined(separator: "\n") + "\n")
        }
        return availability == .available ? ExitStatus.clean : ExitStatus.findings
    }
}

enum StarterSuite {
    static let text = """
        # fmdrift suite: prompts for Apple's on-device model and what each answer must satisfy.
        #
        #   fmdrift run                              check every answer now
        #   fmdrift record                           save the answers for this OS build
        #   fmdrift run --baseline fmdrift-snapshots compare with the saved ones after an OS update
        #
        # Every key: https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat

        name: starter

        defaults:
          # Each case runs three times in new sessions; all three must pass.
          repeat: 3
          instructions: Answer in one short sentence.

        cases:
          - id: capital
            prompt: What is the capital of France?
            expect:
              - contains: Paris
              - maxLength: 120
              - maxLatency: 5s

          - id: ticket-sentiment
            prompt: "Classify this support ticket: 'The app crashes every time I open settings.'"
            # A schema turns on guided generation; the answer is JSON in this shape.
            schema:
              type: object
              required: [sentiment]
              properties:
                sentiment: { type: string, enum: [positive, neutral, negative] }
            expect:
              - path: sentiment
                equals: negative

        """
}
