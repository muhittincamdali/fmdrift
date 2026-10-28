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
}
