import Foundation
import Testing

@testable import FMDriftKit

#if canImport(FoundationModels)
    /// Runs against the real on-device model. Off by default because CI runners have no Apple
    /// Intelligence; run with `FMDRIFT_LIVE=1 swift test --filter Live` on a Mac that has it.
    @Suite(
        "Live on-device model",
        .enabled(if: ProcessInfo.processInfo.environment["FMDRIFT_LIVE"] == "1"),
        .serialized
    )
    struct LiveModelTests {
        @Test func answersAPlainPromptWithLatencyAndTokens() async throws {
            let provider = SystemModelProvider()
            try #require(await provider.availability() == .available, "Apple Intelligence is not available")
            let generation = await provider.generate(
                GenerationRequest(
                    caseID: "capital",
                    prompt: "What is the capital of France? Answer with the city name only.",
                    settings: GenerationSettings(instructions: "Answer in as few words as possible."),
                    schema: nil,
                    sampleIndex: 0
                )
            )
            #expect(generation.failure == nil)
            #expect(generation.text?.contains("Paris") == true)
            #expect(generation.latency > 0)
            #expect((generation.outputTokens ?? 0) > 0)
        }

        @Test func generatesStructuredOutputFromAJSONSchema() async throws {
            let provider = SystemModelProvider()
            try #require(await provider.availability() == .available, "Apple Intelligence is not available")
            let suite = try SuiteLoader.parse(
                """
                cases:
                  - id: ticket
                    prompt: "Classify this support ticket: 'The app crashes every time I open settings. Very annoying.'"
                    schema:
                      type: object
                      required: [sentiment, area, severity]
                      properties:
                        sentiment: { type: string, enum: [positive, neutral, negative] }
                        area: { type: string, description: The part of the app the ticket is about }
                        severity: { type: integer, minimum: 1, maximum: 5 }
                    expect:
                      - path: sentiment
                        equals: negative
                """
            )
            let result = await Runner(provider: provider).run(suite)
            let sample = try #require(result.cases.first?.samples.first)
            #expect(sample.generation.failure == nil)
            #expect(sample.checks.first?.label == Evaluator.schemaLabel)
            #expect(sample.checks.first?.status == .passed)
            #expect(result.environment.provider == "system")
            #expect(result.environment.modelAvailability == "available")
        }
    }
#endif
