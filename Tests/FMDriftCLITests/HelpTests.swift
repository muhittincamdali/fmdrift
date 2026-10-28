import FMDriftKit
import Foundation
import Testing

@testable import FMDriftCLI

@Suite("Help")
struct HelpTests {
    /// A way of asking for a subcommand's help, the usage line it must print and some of the
    /// subcommand's options.
    struct Request: Sendable, CustomTestStringConvertible {
        let arguments: [String]
        let usage: String
        let options: [String]

        var testDescription: String { arguments.joined(separator: " ") }

        static let all: [Request] = [
            Request(
                arguments: ["run", "--help"], usage: "USAGE: fmdrift run",
                options: ["--baseline", "--fail-on", "--junit", "--replay"]),
            Request(arguments: ["run", "-h"], usage: "USAGE: fmdrift run", options: ["--baseline"]),
            Request(arguments: ["help", "run"], usage: "USAGE: fmdrift run", options: ["--baseline", "--junit"]),
            Request(
                arguments: ["diff", "-h"], usage: "USAGE: fmdrift diff",
                options: ["--fail-on", "--max-latency-increase", "--markdown"]),
            Request(arguments: ["help", "diff"], usage: "USAGE: fmdrift diff", options: ["--fail-on"]),
            Request(
                arguments: ["record", "--help"], usage: "USAGE: fmdrift record",
                options: ["--dir", "--replay", "--junit"]),
            Request(arguments: ["validate", "--help"], usage: "USAGE: fmdrift validate", options: ["--no-color"]),
            Request(arguments: ["init", "-h"], usage: "USAGE: fmdrift init", options: ["--output", "--force"]),
            Request(arguments: ["doctor", "--help"], usage: "USAGE: fmdrift doctor", options: ["--json"]),
        ]
    }

    func harness() throws -> Harness {
        try Harness(
            provider: FakeProvider(answers: [:], environmentValue: FakeProvider.environment("27.0.1", "26A434"))
        )
    }

    @Test(arguments: Request.all)
    func printsSubcommandHelp(request: Request) async throws {
        let cli = try harness()
        #expect(await cli.run(request.arguments) == 0)
        #expect(cli.stdout.contains(request.usage))
        #expect(!cli.stdout.contains("USAGE: fmdrift <subcommand>"))
        for option in request.options {
            #expect(cli.stdout.contains(option), "missing \(option)")
        }
        #expect(cli.stderr.isEmpty)
    }

    @Test(arguments: [["--help"], ["-h"], ["help"]])
    func printsTheOverviewWithoutASubcommand(arguments: [String]) async throws {
        let cli = try harness()
        #expect(await cli.run(arguments) == 0)
        #expect(cli.stdout.contains("USAGE: fmdrift <subcommand>"))
        #expect(cli.stdout.contains("run (default)"))
    }
}
