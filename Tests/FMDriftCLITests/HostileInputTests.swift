import FMDriftKit
import Foundation
import Testing

@testable import FMDriftCLI

/// Suite files arrive with pull requests, so the commands must survive whatever they hold.
@Suite("Hostile input")
struct HostileInputTests {
    func harness() throws -> Harness {
        let harness = try Harness(
            provider: FakeProvider(answers: goodAnswers, environmentValue: FakeProvider.environment("27.0.1", "26A434"))
        )
        try harness.write("fmdrift.yaml", supportSuite)
        return harness
    }

    @Test(arguments: [300, 1000])
    func refusesDeeplyNestedSuites(depth: Int) async throws {
        let cli = try harness()
        let flow = String(repeating: "{a: ", count: depth) + "x" + String(repeating: "}", count: depth)
        try cli.write("fmdrift/deep.yaml", "cases:\n  - id: a\n    prompt: p\n    schema: \(flow)\n")
        #expect(await cli.run("validate", "fmdrift") == 1)
        #expect(cli.stdout.hasPrefix("invalid  fmdrift/deep.yaml:4: nests deeper than"))
        #expect(await cli.run("run", "fmdrift") == 2)
        #expect(cli.stderr.contains("fmdrift/deep.yaml:4: nests deeper than"))
    }

    /// A latency of 1e300 in a snapshot made `diff --all`, `diff --markdown` and `run --replay`
    /// trap converting it to Int (exit status 133). Each command now refuses the file.
    @Test func refusesSnapshotsWithOutOfRangeNumbers() async throws {
        let cli = try harness()
        #expect(await cli.run("record") == 0)
        let path = "fmdrift-snapshots/support/macOS-27.0.1-26A434.json"
        let recorded = try cli.read(path)
        #expect(recorded.contains(#""latency" : 0.3"#))
        try cli.write("huge.json", recorded.replacingOccurrences(of: #""latency" : 0.3"#, with: #""latency" : 1e300"#))
        let refusal =
            "error: huge.json: is not a valid snapshot (unexpected value at $.cases[0].samples[0].generation.latency)\n"
        for arguments in [
            ["diff", "huge.json", path, "--all"],
            ["diff", path, "huge.json", "--markdown", "diff.md"],
            ["run", "--replay", "huge.json"],
            ["run", "--baseline", "huge.json"],
        ] {
            #expect(await cli.run(arguments) == 2)
            #expect(cli.stderr == refusal)
        }
        #expect(!cli.exists("diff.md"))
    }

    /// `maxLatency: 1e308s` passed `validate` and then trapped in `run` while formatting the
    /// check's label. Both commands now refuse it.
    @Test func refusesLatencyLimitsBeyondTheLongestTimeout() async throws {
        let cli = try harness()
        try cli.write(
            "fmdrift/slow.yaml",
            "name: slow\ncases:\n  - id: a\n    prompt: hi\n    expect:\n      - maxLatency: 1e308s\n")
        let refusal = "fmdrift/slow.yaml:6: `maxLatency` must be at most 3600s, the longest --timeout"
        #expect(await cli.run("validate", "fmdrift") == 1)
        #expect(cli.stdout == "invalid  \(refusal)\n")
        #expect(await cli.run("run", "fmdrift") == 2)
        #expect(cli.stderr == "error: \(refusal)\n")
    }

    /// A file added to fmdrift/ by a pull request names itself in `validate` and `run` output,
    /// which CI logs show and terminals interpret.
    @Test func escapesFileNamesInMessages() async throws {
        let cli = try harness()
        let hostile = "x\u{1B}]52;c;ZXZpbA==\u{7}\u{1B}[2J\u{202E}"
        let escaped = #"x\u{1B}]52;c;ZXZpbA==\u{7}\u{1B}[2J\u{202E}"#
        try cli.write("fmdrift/\(hostile).yaml", supportSuite.replacingOccurrences(of: "name: support\n", with: ""))
        #expect(await cli.run("validate", "fmdrift") == 0)
        let summary = "suite `x--52-c-ZXZpbA-----2J-`, 2 cases, 2 generations per run"
        #expect(cli.stdout == "ok  fmdrift/\(escaped).yaml: \(summary)\n")

        let invalid = "cases:\n  - id: a\n    prompt: p\n    expect:\n      - contans: x\n"
        try cli.write("fmdrift/\(hostile)-bad.yaml", invalid)
        #expect(await cli.run("validate", "fmdrift") == 1)
        #expect(cli.stdout.contains("invalid  fmdrift/\(escaped)-bad.yaml:5: case `a` check: unknown key `contans`"))
        #expect(await cli.run("run", "fmdrift") == 2)
        #expect(cli.stderr.contains("error: fmdrift/\(escaped)-bad.yaml:5:"))

        for output in [cli.stdout, cli.stderr] {
            #expect(!output.contains("\u{1B}"))
            #expect(!output.contains("\u{7}"))
            #expect(!output.contains("\u{202E}"))
        }
    }

    /// Ten suites in one folder, each with two patterns that backtrack, used to get a budget each:
    /// `run` gave up on twenty matches, waited 2 s for each and left twenty threads running. One
    /// budget now covers every suite of the command.
    @Test func sharesTheRegularExpressionBudgetAcrossSuites() async throws {
        let slowText = String(repeating: "e", count: 24) + "!"
        let cli = try Harness(
            provider: FakeProvider(
                answers: ["slow": [Generation(text: slowText, latency: 0.1)]],
                environmentValue: FakeProvider.environment("27.0.1", "26A434")
            )
        )
        let suiteCount = 10
        for index in 0..<suiteCount {
            let checks = (1...2).map { "      - matches: \"^(e+)+$|cli-\(index)-\($0)\"" }
            try cli.write(
                "slow/s\(index).yaml",
                "name: s\(index)\ncases:\n  - id: slow\n    prompt: p\n    expect:\n" + checks.joined(separator: "\n")
                    + "\n"
            )
        }
        let started = Date()
        #expect(await cli.run("run", "slow") == 1)
        let elapsed = Date().timeIntervalSince(started)

        // Each give-up waits for the 2 s limit of one match.
        #expect(elapsed < Double(PatternBudget.maximumGiveUps) * 2 + 1.5)
        let gaveUp = cli.stdout.components(separatedBy: "— gave up on /").count - 1
        let notTried = cli.stdout.components(separatedBy: "— did not try /").count - 1
        #expect(gaveUp == PatternBudget.maximumGiveUps)
        #expect(notTried == suiteCount * 2 - PatternBudget.maximumGiveUps)
    }
}
