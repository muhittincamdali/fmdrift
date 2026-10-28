import Foundation

/// A suggestion for a failed case, with the Apple documentation it rests on.
public struct Advice: Sendable, Equatable, Codable {
    public var text: String
    public var source: Source

    public init(_ text: String, _ source: Source) {
        self.text = text
        self.source = source
    }

    /// An Apple document the advice is taken from. Read on 28 October 2026.
    public struct Source: Sendable, Equatable, Codable {
        public var title: String
        public var url: String
    }
}

extension Advice.Source {
    static let documentation = "https://developer.apple.com/documentation/foundationmodels/"

    public static let updatingPrompts = Self(
        title: "Updating prompts for new model versions",
        url: documentation + "updating-prompts-for-new-model-versions"
    )
    public static let safety = Self(
        title: "Improving the safety of generative model output",
        url: documentation + "improving-the-safety-of-generative-model-output"
    )
    public static let permissiveGuardrails = Self(
        title: "SystemLanguageModel.Guardrails.permissiveContentTransformations",
        url: documentation + "systemlanguagemodel/guardrails/permissivecontenttransformations"
    )
    public static let contextWindow = Self(
        title: "Managing the context window",
        url: documentation + "managing-the-context-window"
    )
    public static let languages = Self(
        title: "Supporting languages and locales with Foundation Models",
        url: documentation + "supporting-languages-and-locales-with-foundation-models"
    )
    public static let guidedGeneration = Self(
        title: "Generating Swift data structures with guided generation",
        url: documentation + "generating-swift-data-structures-with-guided-generation"
    )
    public static let prompting = Self(
        title: "Prompting an on-device foundation model",
        url: documentation + "prompting-an-on-device-foundation-model"
    )
    public static let performance = Self(
        title: "Analyzing the runtime performance of your Foundation Models app",
        url: documentation + "analyzing-the-runtime-performance-of-your-foundation-models-app"
    )
    public static let evaluating = Self(
        title: "Evaluating prompts to measure performance and improve model responses",
        url: documentation + "evaluating-prompts-to-measure-performance-and-improve-model-responses"
    )
    public static let availability = Self(
        title: "SystemLanguageModel.Availability",
        url: documentation + "systemlanguagemodel/availability-swift.enum"
    )

    /// Every source fmdrift's advice cites, for the README and `fmdrift doctor`.
    public static let all: [Self] = [
        updatingPrompts, evaluating, prompting, guidedGeneration, safety, permissiveGuardrails, contextWindow,
        languages, performance, availability,
    ]
}

extension Advice {
    /// What to try for a case that failed, most specific first; at most three entries.
    public static func forFailedCase(_ result: CaseResult) -> [Advice] {
        var advice: [Advice] = []
        func add(_ item: Advice) {
            if !advice.contains(item) { advice.append(item) }
        }
        let failures = result.samples.compactMap(\.generation.failure)
        let failedChecks = result.samples.flatMap { $0.checks.filter { $0.status == .failed } }
        let expectsDecline = failedChecks.contains { $0.label == "model declines" }

        for failure in failures {
            if let item = forFailure(failure, settings: result.settings, expectsDecline: expectsDecline) {
                add(item)
            }
        }
        if failures.isEmpty, expectsDecline {
            add(
                Advice(
                    "The model answered where the case expects a decline. A refusal can also arrive as text such as “Sorry, I can’t help…”, which is not an error; check for it with `containsAny` instead of `refusal: true`.",
                    .safety
                )
            )
        }
        for check in failedChecks {
            if let item = forCheck(check) { add(item) }
        }
        if result.passCount > 0, result.passCount < result.samples.count {
            add(
                Advice(
                    "Some responses passed and some did not. Make the instructions more specific, give an example of the output you want, or use greedy sampling where the answer must not vary.",
                    .prompting
                )
            )
        }
        if advice.isEmpty {
            add(
                Advice(
                    "Rewrite the prompt in short, specific sentences and say exactly what the output must contain.",
                    .prompting
                )
            )
        }
        return Array(advice.prefix(3))
    }

    static func forFailure(_ failure: GenerationFailure, settings: GenerationSettings, expectsDecline: Bool)
        -> Advice?
    {
        switch failure.kind {
        case .guardrailViolation where !expectsDecline:
            if settings.guardrails == .default {
                return Advice(
                    "The guardrails flagged the prompt or the response. If the prompt transforms text a person supplied (summarize, rewrite, tag), try `guardrails: permissiveContentTransformations`; it applies to text responses only.",
                    .permissiveGuardrails
                )
            }
            return Advice(
                "The guardrails flagged this prompt even with permissive guardrails, which only cover text responses. Reword the request or handle the error in the app.",
                .safety
            )
        case .refusal where !expectsDecline:
            return Advice(
                "The model refused. The on-device model is not suitable for every topic; reword the request or design the feature to present the refusal.",
                .safety
            )
        case .contextWindowExceeded:
            return Advice(
                "Instructions, prompt, schema and response together exceed the context window; `fmdrift doctor` shows its size on this Mac. Shorten them or lower `maxResponseTokens`.",
                .contextWindow
            )
        case .unsupportedLanguageOrLocale:
            return Advice(
                "The model does not support a language in the prompt. Check `supportsLocale(_:)` before calling the model and keep the prompt in a supported language.",
                .languages
            )
        case .unsupportedGuide, .decodingFailure:
            return Advice(
                "Guided generation could not produce the schema. Simplify it: fewer nested objects and patterns the model can follow.",
                .guidedGeneration
            )
        case .assetsUnavailable, .modelUnavailable:
            return Advice(
                "The model was not available. Run `fmdrift doctor` to see why, then run the suite again.",
                .availability
            )
        case .timeout:
            return Advice(
                "The response did not arrive in time. Lower `maxResponseTokens`, or raise `--timeout` if long answers are expected.",
                .performance
            )
        default:
            return nil
        }
    }

    static func forCheck(_ check: CheckResult) -> Advice? {
        let label = check.label
        if label == Evaluator.schemaLabel {
            return Advice(
                "The structured response does not match the schema. Guided generation enforces structure; describe each property with `description` so the model fills in the right values.",
                .guidedGeneration
            )
        }
        if label.hasPrefix("latency") {
            return Advice(
                "Latency grows with the tokens read and written. Lower `maxResponseTokens`, shorten the instructions, and profile with the Foundation Models instrument; in the app, `prewarm(promptPrefix:)` loads the model before the request.",
                .performance
            )
        }
        if label.hasPrefix("output tokens") {
            return Advice(
                "The response is longer than allowed. Ask for the length you want in the instructions, or cap it with `maxResponseTokens`.",
                .contextWindow
            )
        }
        if label.contains("matches") || label.contains("equals") || label.contains("is one of") {
            return Advice(
                "When the output must follow a fixed format or vocabulary, use a `schema` with `enum` or `pattern` so guided generation enforces it.",
                .guidedGeneration
            )
        }
        return nil
    }

    /// What to do when a case passed on the baseline OS build and fails on the current one.
    public static let regression = Advice(
        "The case passed on the baseline OS build and fails on this one. Compare the outputs; if the new model needs other wording, keep a prompt version per OS release and pick it with `if #available`.",
        .updatingPrompts
    )
}
