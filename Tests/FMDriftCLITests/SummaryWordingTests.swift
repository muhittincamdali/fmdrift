import FMDriftKit
import Foundation
import Testing

@testable import FMDriftCLI

@Suite("Summary wording")
struct SummaryWordingTests {
    func harness() throws -> Harness {
        let harness = try Harness(
            provider: FakeProvider(answers: goodAnswers, environmentValue: FakeProvider.environment("27.0.1", "26A434"))
        )
        try harness.write("fmdrift.yaml", supportSuite)
        return harness
    }

    @Test func validateCountsInTheSingular() async throws {
        let cli = try harness()
        let suite = "name: one\ncases:\n  - id: capital\n    prompt: p\n    expect:\n      - contains: x\n"
        try cli.write("one.yaml", suite)
        #expect(await cli.run("validate", "one.yaml") == 0)
        #expect(cli.stdout == "ok  one.yaml: suite `one`, 1 case, 1 generation per run\n")
    }

    /// A replay generates nothing, so its summary counts the recorded responses it checked.
    @Test func replaySaysItCheckedRecordedResponses() async throws {
        let cli = try harness()
        #expect(await cli.run("record") == 0)
        #expect(cli.stdout.contains("2 cases · 2 passed · 0 failed · 2 generations in "))
        #expect(await cli.run("run", "--replay", "fmdrift-snapshots", "--markdown", "replay.md") == 0)
        #expect(cli.stdout.contains("2 cases · 2 passed · 0 failed · 2 recorded responses checked in "))
        #expect(!cli.stdout.contains("generations in"))
        let markdown = try cli.read("replay.md")
        #expect(markdown.contains("2 of 2 cases passed · 2 recorded responses checked in "))
    }
}
