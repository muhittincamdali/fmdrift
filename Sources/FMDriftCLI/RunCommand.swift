import ArgumentParser
import FMDriftKit
import Foundation

/// Options shared by `run` and `record`.
struct RunOptions: ParsableArguments {
    @Argument(
        help: ArgumentHelp(
            "Suite files, or folders of them. Default: fmdrift.yaml, or the files in fmdrift/.",
            valueName: "suite"
        )
    )
    var suites: [String] = []

    @Option(name: .customLong("case"), help: ArgumentHelp("Run only this case id. Repeat for more.", valueName: "id"))
    var cases: [String] = []

    @Option(
        name: .customLong("repeat"),
        help: ArgumentHelp("Run each case this many times instead of its `repeat`.", valueName: "n"))
    var repeatCount: Int?

    @Option(help: ArgumentHelp("Seconds to wait for one response.", valueName: "seconds"))
    var timeout: Double = 120

    @Option(
        help: ArgumentHelp(
            "Check the responses stored in a snapshot (file, or folder of snapshots) instead of asking the model.",
            valueName: "snapshot"
        )
    )
    var replay: String?

    @Flag(
        help:
            "Exit with 0 and a note when the on-device model is not available, for CI runners without Apple Intelligence."
    )
    var allowUnavailable = false

    @Flag(help: "Print the results as JSON instead of the report.")
    var json = false

    @Option(help: ArgumentHelp("Also write the results as JUnit XML to this file.", valueName: "path"))
    var junit: String?

    @Option(help: ArgumentHelp("Also write the report as Markdown to this file.", valueName: "path"))
    var markdown: String?

    @Flag(help: "Do not color the report.")
    var noColor = false

    func validate() throws {
        if let repeatCount, !(1...SuiteLoader.maximumRepeat).contains(repeatCount) {
            throw ValidationError("--repeat must be between 1 and \(SuiteLoader.maximumRepeat)")
        }
        guard timeout > 0, timeout <= 3600 else {
            throw ValidationError("--timeout must be between 0 and 3600 seconds")
        }
        if replay != nil, repeatCount != nil {
            throw ValidationError("--replay checks the recorded responses; it cannot be combined with --repeat")
        }
    }
}

struct RunCommand: ContextCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Run the suites on the on-device model and check every response (the default command).",
        discussion: """
            With --baseline, each suite is also compared with a snapshot recorded earlier. Given a folder (such as fmdrift-snapshots), the newest snapshot of the suite from another OS build is used, or the newest one when there is no other build.
            """
    )

    @OptionGroup var options: RunOptions

    @Option(
        help: ArgumentHelp(
            "Compare with this snapshot, or the newest suitable one in this folder.",
            valueName: "snapshot"
        )
    )
    var baseline: String?

    @Option(
        help: ArgumentHelp(
            "What fails the run when comparing: regressed (a passing case now fails, or is slower than allowed), changed (any difference) or never.",
            valueName: "policy"
        )
    )
    var failOn: FailOn = .regressed

    @Option(
        help: ArgumentHelp(
            "Mark a case slower when its median latency grows by more than this, e.g. 50%.",
            valueName: "share"
        )
    )
    var maxLatencyIncrease: String?

    func validate() throws {
        _ = try LatencyShare.parse(maxLatencyIncrease)
    }

    func execute(_ context: Context) async -> Int32 {
        let comparison = Comparison(
            path: baseline,
            policy: failOn.policy,
            latencyIncrease: (try? LatencyShare.parse(maxLatencyIncrease)) ?? nil
        )
        return await SuiteRun(options: options, mode: .run(comparison)).execute(context)
    }
}

struct RecordCommand: ContextCommand {
    static let configuration = CommandConfiguration(
        commandName: "record",
        abstract: "Run the suites and save the results as snapshots, one file per suite and OS build.",
        discussion: """
            Snapshots go to <dir>/<suite>/<platform>-<version>-<build>.json, for example fmdrift-snapshots/support/macOS-27.0.1-26A434.json. Commit them: a later run on a new OS build compares against them with --baseline.
            """
    )

    @OptionGroup var options: RunOptions

    @Option(help: ArgumentHelp("Folder for the snapshots.", valueName: "dir"))
    var dir: String = "fmdrift-snapshots"

    func validate() throws {
        if options.replay != nil {
            throw ValidationError("record saves new responses; use run --replay to check recorded ones")
        }
    }

    func execute(_ context: Context) async -> Int32 {
        await SuiteRun(options: options, mode: .record(directory: dir)).execute(context)
    }
}

enum FailOn: String, ExpressibleByArgument, CaseIterable {
    case regressed, changed, never

    var policy: SnapshotDiff.FailurePolicy {
        switch self {
        case .regressed: .regressed
        case .changed: .changed
        case .never: .never
        }
    }
}

enum LatencyShare {
    /// `50%` or `0.5` → 0.5.
    static func parse(_ text: String?) throws -> Double? {
        guard let text else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let value = trimmed.hasSuffix("%") ? Double(trimmed.dropLast()).map { $0 / 100 } : Double(trimmed)
        guard let value, value >= 0, value.isFinite else {
            throw ValidationError("--max-latency-increase takes a share such as 50% or 0.5")
        }
        return value
    }
}

struct Comparison {
    var path: String?
    var policy: SnapshotDiff.FailurePolicy
    var latencyIncrease: Double?
}
