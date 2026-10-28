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
}
