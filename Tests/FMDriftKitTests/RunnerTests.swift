import Foundation
import Testing

@testable import FMDriftKit

/// Answers from a fixed list per case, in order; used where a model is not available.
struct ScriptedProvider: ModelProvider {
    var answers: [String: [Generation]]
    var environmentValue = RunEnvironment(
        platform: "macOS",
        osVersion: "27.0.1",
        osBuild: "26A434",
        provider: "scripted",
        modelAvailability: "available"
    )

    func availability() async -> ModelAvailability { .available }
    func environment() async -> RunEnvironment { environmentValue }
    func generate(_ request: GenerationRequest) async -> Generation {
        guard let list = answers[request.caseID], !list.isEmpty else {
            return .failed(.other, "no scripted answer", latency: 0)
        }
        return list[request.sampleIndex % list.count]
    }
}

@Suite("Runs")
struct RunnerTests {
    let suite = try! SuiteLoader.parse(
        """
        name: demo
        cases:
          - id: capital
            prompt: Capital of France?
            repeat: 3
            minPassRate: 0.6
            expect:
              - contains: Paris
          - id: refuse
            prompt: Something unsafe
            expect:
              - refusal: true
        """
    )

    @Test func runsEveryRepeatAndComputesRatesAndAgreement() async throws {
        let provider = ScriptedProvider(answers: [
            "capital": [
                Generation(text: "Paris", latency: 0.4123456, outputTokens: 2),
                Generation(text: "Paris", latency: 0.6, outputTokens: 2),
                Generation(text: "Lyon", latency: 0.5, outputTokens: 3),
            ],
            "refuse": [.failed(.guardrailViolation, "Unsafe", latency: 0.1)],
        ])
        let events = EventLog()
        let result = await Runner(provider: provider).run(suite, progress: { events.append($0) })

        #expect(result.suite == "demo")
        #expect(result.environment.provider == "scripted")
        #expect(result.cases.map(\.id) == ["capital", "refuse"])
        let capital = result.cases[0]
        #expect(capital.samples.count == 3)
        #expect(capital.passCount == 2)
        #expect(abs(capital.passRate - 2.0 / 3) < 1e-9)
        #expect(capital.passed)
        #expect(abs(capital.agreement - 2.0 / 3) < 1e-9)
        #expect(capital.representativeOutput == "Paris")
        #expect(capital.samples[0].generation.latency == 0.412)
        #expect(capital.medianLatency == 0.5)
        #expect(capital.medianOutputTokens == 2)
        #expect(capital.fingerprint == suite.cases[0].fingerprint)
        #expect(result.cases[1].passed)
        #expect(result.cases[1].representativeOutput == "[guardrailViolation]")
        #expect(result.passed)
        #expect(result.generationCount == 4)
        #expect(events.items.map(\.completed) == [1, 2, 3, 4])
        #expect(events.items.allSatisfy { $0.total == 4 })
    }

    @Test func structuredAnswersAgreeWhateverTheKeyOrder() async throws {
        // Recorded on macOS 27.0.1 (26A434): ten greedy runs of one triage prompt gave the same
        // three values in four different key orders.
        let structured = try SuiteLoader.parse(
            """
            cases:
              - id: triage
                prompt: Triage
                repeat: 3
                schema:
                  type: object
                  properties:
                    category: { type: string }
                    urgency: { type: integer }
            """
        )
        let provider = ScriptedProvider(answers: [
            "triage": [
                Generation(text: #"{"category": "bug", "urgency": 5}"#, latency: 0.5),
                Generation(text: #"{"urgency": 5, "category": "bug"}"#, latency: 0.5),
                Generation(text: #"{"urgency": 4, "category": "bug"}"#, latency: 0.5),
            ]
        ])
        let result = await Runner(provider: provider).run(structured)
        #expect(abs(result.cases[0].agreement - 2.0 / 3) < 1e-9)
        #expect(result.cases[0].representativeOutput == #"{"category":"bug","urgency":5}"#)
        // The recorded text stays as the model wrote it.
        #expect(result.cases[0].samples[1].generation.text == #"{"urgency": 5, "category": "bug"}"#)
    }

    @Test func aCaseFailsBelowItsPassRate() async {
        let provider = ScriptedProvider(answers: [
            "capital": [Generation(text: "Lyon", latency: 0.1), Generation(text: "Paris", latency: 0.1)],
            "refuse": [Generation(text: "Sure, here you go", latency: 0.1)],
        ])
        let result = await Runner(provider: provider).run(suite)
        #expect(result.cases[0].passCount == 1)
        #expect(!result.cases[0].passed)
        #expect(!result.cases[1].passed)
        #expect(!result.passed)
        #expect(result.failedCount == 2)
    }

    @Test func selectsCasesAndOverridesTheSampleCount() async {
        let provider = ScriptedProvider(answers: ["capital": [Generation(text: "Paris", latency: 0.1)]])
        let result = await Runner(provider: provider).run(suite, cases: ["capital"], sampleCount: { _ in 5 })
        #expect(result.cases.map(\.id) == ["capital"])
        #expect(result.cases[0].samples.count == 5)

        let none = await Runner(provider: provider).run(suite, cases: ["capital"], sampleCount: { _ in 0 })
        #expect(!none.cases[0].passed)
        #expect(none.cases[0].notes == ["no responses to check"])
    }

    @Test func replaysASnapshot() async throws {
        let provider = ScriptedProvider(answers: [
            "capital": [Generation(text: "Paris", latency: 0.2)],
            "refuse": [.failed(.refusal, "No", latency: 0.1)],
        ])
        let recorded = await Runner(provider: provider).run(suite)
        let replay = ReplayProvider(snapshot: recorded)
        #expect(replay.recordedCount(for: "capital") == 3)
        #expect(replay.recordedCount(for: "missing") == 0)
        #expect(await replay.environment().provider == "replay")

        let replayed = await Runner(provider: replay).run(suite, sampleCount: { replay.recordedCount(for: $0.id) })
        #expect(replayed.cases.map(\.samples) == recorded.cases.map(\.samples))

        let missing = await replay.generate(
            GenerationRequest(caseID: "capital", prompt: "p", settings: .init(), schema: nil, sampleIndex: 7)
        )
        #expect(missing.failure?.message == "the snapshot has no response 8 for case `capital`")
    }

    @Test func roundTripsThroughJSONAndRecomputesOutcomes() async throws {
        let provider = ScriptedProvider(answers: [
            "capital": [Generation(text: "Paris", latency: 0.2, outputTokens: 1, inputTokens: 30)],
            "refuse": [.failed(.refusal, "No", latency: 0.1)],
        ])
        let result = await Runner(provider: provider).run(suite)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try encoder.encode(result)
        var decoded = try decoder.decode(RunResult.self, from: data)
        decoded.recordedAt = result.recordedAt
        #expect(decoded == result)

        // A hand-edited "passed": true does not survive decoding when a check failed.
        var text = String(decoding: data, as: UTF8.self)
        text = text.replacingOccurrences(of: #""status":"passed""#, with: #""status":"failed""#)
        let tampered = try decoder.decode(RunResult.self, from: Data(text.utf8))
        #expect(!tampered.cases[0].passed)
    }
}

@Suite("Environment and errors")
struct EnvironmentTests {
    @Test func namesSnapshotsSafely() {
        let environment = RunEnvironment(
            platform: "macOS",
            osVersion: "27.0.1",
            osBuild: "26A434",
            provider: "system",
            modelAvailability: "available"
        )
        #expect(environment.snapshotName == "macOS-27.0.1-26A434")
        #expect(environment.osLabel == "macOS 27.0.1 (26A434)")
        var odd = environment
        odd.osBuild = "../../x y"
        #expect(odd.snapshotName == "macOS-27.0.1-..-..-x-y")
        #expect(!odd.snapshotName.contains("/"))
    }

    @Test func readsTheHost() {
        let host = RunEnvironment.host(provider: "system", modelAvailability: "available", contextSize: 4096)
        #expect(host.platform == "macOS")
        #expect(host.osVersion.split(separator: ".").count >= 2)
        #expect(!host.osBuild.isEmpty)
        #expect(host.contextSize == 4096)
    }

    @Test(arguments: [
        ("guardrailViolation", GenerationFailure.Kind.guardrailViolation),
        ("refusal", .refusal),
        ("exceededContextWindowSize", .contextWindowExceeded),
        ("contextSizeExceeded", .contextWindowExceeded),
        ("unsupportedLanguageOrLocale", .unsupportedLanguageOrLocale),
        ("unsupportedGuide", .unsupportedGuide),
        ("unsupportedGenerationGuide", .unsupportedGuide),
        ("decodingFailure", .decodingFailure),
        ("assetsUnavailable", .assetsUnavailable),
        ("rateLimited", .rateLimited),
        ("concurrentRequests", .concurrentRequests),
        ("timeout", .timeout),
        ("somethingNew", .other),
    ])
    func classifiesFrameworkErrorCases(name: String, kind: GenerationFailure.Kind) {
        #expect(ErrorClassifier.kind(forCase: name) == kind)
    }

    enum LocalError: Error {
        case guardrailViolation(String)
    }

    @Test func leavesOtherModulesErrorsAlone() {
        // Same case name, but not a FoundationModels error.
        #expect(ErrorClassifier.failure(from: LocalError.guardrailViolation("x")).kind == .other)
        #expect(ErrorClassifier.failure(from: CancellationError()).kind == .timeout)
        #expect(ErrorClassifier.caseName(of: LocalError.guardrailViolation("x")) == "guardrailViolation")
    }
}

final class EventLog: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [Runner.Progress] = []

    func append(_ event: Runner.Progress) {
        lock.withLock { storage.append(event) }
    }

    var items: [Runner.Progress] {
        lock.withLock { storage }
    }
}
