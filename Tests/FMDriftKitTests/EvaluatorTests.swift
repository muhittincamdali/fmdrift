import Foundation
import Testing

@testable import FMDriftKit

@Suite("Checks on one response")
struct EvaluatorTests {
    private func run(
        _ kind: Assertion.Kind,
        on text: String?,
        path: [String]? = nil,
        ignoreCase: Bool = false,
        schema: JSONSchema? = nil,
        latency: Double = 0.5,
        tokens: Int? = 12,
        failure: GenerationFailure? = nil
    ) -> [CheckResult] {
        let testCase = TestCase(
            id: "t",
            prompt: "p",
            schema: schema,
            assertions: [Assertion(kind, path: path, ignoreCase: ignoreCase)]
        )
        let generation = Generation(text: text, latency: latency, outputTokens: tokens, failure: failure)
        return Evaluator.evaluate(generation, for: testCase)
    }

    private func status(_ kind: Assertion.Kind, on text: String?, ignoreCase: Bool = false) -> CheckResult.Status? {
        run(kind, on: text, ignoreCase: ignoreCase).last?.status
    }

    @Test func textChecks() {
        #expect(status(.contains(["Paris"]), on: "It is Paris.") == .passed)
        #expect(status(.contains(["Paris", "France"]), on: "It is Paris.") == .failed)
        #expect(status(.contains(["paris"]), on: "It is Paris.") == .failed)
        #expect(status(.contains(["paris"]), on: "It is Paris.", ignoreCase: true) == .passed)
        #expect(status(.containsAny(["Lyon", "Paris"]), on: "Paris") == .passed)
        #expect(status(.containsAny(["Lyon", "Nice"]), on: "Paris") == .failed)
        #expect(status(.notContains(["sorry"]), on: "Paris") == .passed)
        #expect(status(.notContains(["Sorry"]), on: "sorry", ignoreCase: true) == .failed)
        #expect(status(.equals(.string("Paris")), on: "  Paris\n") == .passed)
        #expect(status(.equals(.string("paris")), on: "Paris", ignoreCase: true) == .passed)
        #expect(status(.equals(.number(4)), on: "4") == .passed)
        #expect(status(.oneOf([.string("yes"), .string("no")]), on: "No", ignoreCase: true) == .passed)
        #expect(status(.oneOf([.string("yes"), .string("no")]), on: "maybe") == .failed)
        #expect(status(.matches(#"^\d{4}$"#), on: "2026") == .passed)
        #expect(status(.matches(#"^\d{4}$"#), on: "year 2026") == .failed)
        #expect(status(.notMatches("(?i)as an ai"), on: "As an AI model") == .failed)
        #expect(status(.minLength(3), on: "abc") == .passed)
        #expect(status(.maxLength(2), on: "abc") == .failed)
        #expect(status(.atLeast(3), on: " 4 ") == .passed)
        #expect(status(.atMost(3), on: "4") == .failed)
        #expect(status(.atMost(3), on: "four") == .failed)
    }

    @Test func failureDetailsSayWhatWasFound() {
        #expect(
            run(.contains(["Paris", "France"]), on: "It is Paris.")[0].detail == #"missing "France" in "It is Paris.""#)
        #expect(run(.maxLength(5), on: "abcdefgh")[0].detail == "8 characters")
        #expect(run(.notContains(["x"]), on: "xyz")[0].detail == #"found "x" in "xyz""#)
        #expect(run(.maxLatency(1), on: "a", latency: 1.5)[0].detail == "took 1.50 s")
        #expect(run(.maxOutputTokens(10), on: "a", tokens: 25)[0].detail == "25 tokens")
        let long = String(repeating: "word ", count: 30)
        #expect(run(.contains(["zzz"]), on: long)[0].detail?.hasSuffix("…\"") == true)
    }

    @Test func latencyAndTokens() {
        #expect(run(.maxLatency(1), on: "a", latency: 0.99)[0].status == .passed)
        #expect(run(.maxLatency(1), on: "a", latency: 1.01)[0].status == .failed)
        #expect(run(.maxOutputTokens(12), on: "a", tokens: 12)[0].status == .passed)
        let unknown = run(.maxOutputTokens(12), on: "a", tokens: nil)[0]
        #expect(unknown.status == .skipped)
        #expect(unknown.detail == "this OS does not report token counts")
    }

    @Test func structuredOutputIsCheckedAgainstTheSchemaAndPaths() {
        let schema = JSONSchema.object(
            properties: [
                .init(
                    name: "mood",
                    schema: .string(enumValues: ["happy", "sad"], pattern: nil, description: nil),
                    isRequired: true
                ),
                .init(
                    name: "tags",
                    schema: .array(
                        items: .string(enumValues: nil, pattern: nil, description: nil),
                        minItems: nil,
                        maxItems: 2,
                        description: nil
                    ),
                    isRequired: false
                ),
            ],
            description: nil
        )
        let good = run(
            .equals(.string("happy")), on: #"{"mood": "happy", "tags": ["a"]}"#, path: ["mood"], schema: schema)
        #expect(good.map(\.status) == [.passed, .passed])
        #expect(good[0].label == Evaluator.schemaLabel)

        let wrong = run(
            .maxLength(1), on: #"{"mood": "angry", "tags": ["a", "b", "c"]}"#, path: ["tags"], schema: schema)
        #expect(wrong[0].status == .failed)
        #expect(
            wrong[0].detail == #"$.mood: "angry" is not one of "happy", "sad"; $.tags: 3 items, expected at most 2"#)
        #expect(wrong[1].detail == "3 items")

        let missing = run(.equals(.string("x")), on: #"{"mood": "sad"}"#, path: ["tags", "0"], schema: schema)
        #expect(missing[1].detail == "no value at `tags.0`")

        let notJSON = run(.equals(.string("x")), on: "plain words", path: ["mood"], schema: schema)
        #expect(notJSON.map(\.detail) == ["the response is not JSON", "the response is not JSON"])

        let numberAtPath = run(
            .equals(.number(3)),
            on: #"{"n": 3}"#,
            path: ["n"],
            schema: .object(
                properties: [
                    .init(name: "n", schema: .integer(minimum: 5, maximum: nil, description: nil), isRequired: true)
                ],
                description: nil
            )
        )
        #expect(numberAtPath.map(\.status) == [.failed, .passed])
        #expect(numberAtPath[0].detail == "$.n: 3 is below the minimum 5")
    }

    @Test func aFailedGenerationFailsTheCaseUnlessADeclineIsExpected() {
        let guardrail = GenerationFailure(kind: .guardrailViolation, message: "Unsafe content")
        let failed = run(.contains(["x"]), on: nil, failure: guardrail)
        #expect(failed.map(\.label) == [Evaluator.answerLabel, #"contains "x""#])
        #expect(failed.map(\.status) == [.failed, .failed])
        #expect(failed[0].detail == "guardrailViolation: Unsafe content")

        let declineExpected = TestCase(
            id: "t",
            prompt: "p",
            assertions: [Assertion(.refusal(true)), Assertion(.notContains(["recipe"]))]
        )
        let declined = Evaluator.evaluate(
            Generation.failed(.guardrailViolation, "Unsafe", latency: 0.2), for: declineExpected)
        #expect(declined.map(\.status) == [.passed, .skipped])

        let answered = Evaluator.evaluate(Generation(text: "Here is a recipe", latency: 0.2), for: declineExpected)
        #expect(answered.map(\.status) == [.failed, .failed])
        #expect(answered[0].detail == #"answered: "Here is a recipe""#)

        let otherError = Evaluator.evaluate(
            Generation.failed(.contextWindowExceeded, "Too long", latency: 0.2),
            for: declineExpected
        )
        #expect(otherError[0].detail == "failed with contextWindowExceeded instead: Too long")

        let mustAnswer = TestCase(id: "t", prompt: "p", assertions: [Assertion(.refusal(false))])
        #expect(Evaluator.evaluate(Generation(text: "ok", latency: 0.1), for: mustAnswer).map(\.status) == [.passed])
        #expect(
            Evaluator.evaluate(Generation.failed(.refusal, "No", latency: 0.1), for: mustAnswer).map(\.detail)
                == ["refusal: No"]
        )
    }
}

@Suite("Labels")
struct AssertionLabelTests {
    @Test func readLikeTheSuite() {
        #expect(Assertion(.contains(["a", "b"]), ignoreCase: true).label == #"contains "a", "b" (ignoring case)"#)
        #expect(Assertion(.equals(.string("x")), path: ["a", "0"]).label == #"a.0 equals "x""#)
        #expect(Assertion(.maxLatency(0.8)).label == "latency ≤ 800 ms")
        #expect(Assertion(.maxLatency(2)).label == "latency ≤ 2.00 s")
        #expect(Assertion(.atMost(2.5)).label == "≤ 2.5")
        #expect(Assertion(.refusal(true)).label == "model declines")
        #expect(Assertion(.matches("^a$")).label == "matches /^a$/")
    }

    @Test func formatNumbersAndChanges() {
        #expect(Format.number(3) == "3")
        #expect(Format.number(0.125) == "0.125")
        #expect(Format.number(1.0 / 3) == "0.333")
        #expect(Format.duration(125) == "2 min 5 s")
        #expect(Format.percent(2.0 / 3) == "67%")
        #expect(Format.change(from: 100, to: 150) == "+50%")
        #expect(Format.change(from: 100, to: 100.2) == "±0%")
        #expect(Format.change(from: 100, to: 80) == "-20%")
        #expect(Format.change(from: 0, to: 80) == nil)
    }

    /// Snapshots are untrusted: a latency of 1e300 once trapped converting to Int.
    @Test func formatOutOfRangeValuesWithoutTrapping() {
        #expect(Format.duration(1e300).hasSuffix(" s"))
        #expect(Format.duration(1e15) == "16666666666666 min 40 s")
        #expect(Format.duration(.infinity) == "–")
        #expect(Format.duration(.nan) == "–")
        #expect(Format.duration(-1e300) == "–")
        #expect(Format.duration(3600) == "60 min 0 s")
        #expect(Format.percent(1e300).hasSuffix("%"))
        #expect(Format.percent(-1e300).hasSuffix("%"))
        #expect(Format.change(from: 1e-300, to: 3) == ">+999999%")
        #expect(Format.change(from: 0.5, to: 1e300) == ">+999999%")
        #expect(Format.change(from: 5e-324, to: 1) == ">+999999%")
        #expect(Format.change(from: 1, to: .infinity) == nil)
        #expect(Format.change(from: 1, to: -1e300) == "<-999999%")
        #expect(Format.change(from: 1, to: 10_000) == "+999900%")
    }
}
