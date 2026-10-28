import FMDriftKit
import Foundation
import Testing

@testable import FMDriftCLI

/// Checks the snapshot recorded on a real Mac in Examples/support-app against the suite next to
/// it, through the command line. It fails when a change to the checks, the evaluator or the
/// snapshot format would turn the recorded answers into failures.
@Suite("Recorded example")
struct RecordedExampleTests {
    static let example = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Examples/support-app")

    func harness() throws -> Harness {
        let harness = try Harness(
            provider: FakeProvider(
                answers: [:],
                environmentValue: FakeProvider.environment("27.0.1", "26A434"),
                availabilityValue: .unavailable(reason: "deviceNotEligible", explanation: "Not used.")
            )
        )
        let fileManager = FileManager.default
        for name in ["fmdrift", "fmdrift-snapshots"] {
            try fileManager.copyItem(
                at: Self.example.appendingPathComponent(name),
                to: harness.directory.appendingPathComponent(name)
            )
        }
        return harness
    }

    @Test func theRecordingIsARealRunOfTheSuite() throws {
        let snapshot = try SnapshotStore.read(
            contentsOf: Self.example.appendingPathComponent("fmdrift-snapshots/support/macOS-27.0.1-26A434.json")
        )
        let suite = try SuiteLoader.load(contentsOf: Self.example.appendingPathComponent("fmdrift/support.yaml"))
        #expect(snapshot.environment.provider == "system")
        #expect(snapshot.environment.osLabel == "macOS 27.0.1 (26A434)")
        #expect(snapshot.environment.modelAvailability == "available")
        #expect(snapshot.cases.map(\.id) == suite.cases.map(\.id))
        #expect(snapshot.cases.map(\.fingerprint) == suite.cases.map(\.fingerprint))
        #expect(snapshot.generationCount == 15)
        #expect(snapshot.cases.allSatisfy { $0.samples.allSatisfy { $0.generation.latency > 0 } })
    }

    @Test func theRecordedAnswersPassTheSuite() async throws {
        let cli = try harness()
        #expect(await cli.run("validate") == 0)
        #expect(await cli.run("run", "--replay", "fmdrift-snapshots") == 0)
        #expect(cli.stdout.contains("5 cases · 5 passed · 0 failed · 15 recorded responses checked in "))
        #expect(!cli.stdout.contains("note:"))
    }

    @Test func aStricterCheckFailsOnTheRecordedAnswers() async throws {
        let cli = try harness()
        let suite = try cli.read("fmdrift/support.yaml")
        try cli.write("fmdrift/support.yaml", suite.replacingOccurrences(of: "maxLength: 240", with: "maxLength: 20"))
        #expect(await cli.run("run", "--replay", "fmdrift-snapshots") == 1)
        #expect(cli.stdout.contains(" FAIL  ticket-summary"))
        #expect(cli.stdout.contains("✗ length ≤ 20"))
    }
}
