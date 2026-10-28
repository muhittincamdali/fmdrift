import Foundation

/// One response from the model, or the error it gave instead.
public struct Generation: Sendable, Equatable, Codable {
    /// The response text. For a case with a schema, the generated content as JSON.
    public var text: String?
    /// Seconds from sending the prompt to the complete response (or the error).
    public var latency: Double
    /// Tokens in the response; nil when the OS cannot count them.
    public var outputTokens: Int?
    /// Tokens the model read: instructions, prompt and schema; nil when unknown.
    public var inputTokens: Int?
    public var failure: GenerationFailure?

    public init(
        text: String?,
        latency: Double,
        outputTokens: Int? = nil,
        inputTokens: Int? = nil,
        failure: GenerationFailure? = nil
    ) {
        self.text = text
        self.latency = latency
        self.outputTokens = outputTokens
        self.inputTokens = inputTokens
        self.failure = failure
    }

    public static func failed(_ kind: GenerationFailure.Kind, _ message: String, latency: Double) -> Generation {
        Generation(text: nil, latency: latency, failure: GenerationFailure(kind: kind, message: message))
    }

    /// The longest a generation may wait for the model: the upper bound of `--timeout` and of a
    /// suite's `maxLatency`.
    public static let maximumWait: Double = 3600

    /// Snapshots with a longer recorded latency are refused. A day leaves room above
    /// ``maximumWait`` for a timed-out generation that returned late.
    public static let maximumRecordedLatency: Double = 86_400

    /// Snapshots are untrusted, so the numbers are checked: a latency of 1e300 has no meaning
    /// and only reaches the reports' arithmetic.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latency = try container.decode(Double.self, forKey: .latency)
        guard latency.isFinite, latency >= 0, latency <= Self.maximumRecordedLatency else {
            throw DecodingError.dataCorruptedError(
                forKey: .latency,
                in: container,
                debugDescription: "latency must be between 0 and \(Self.maximumRecordedLatency) seconds"
            )
        }
        let outputTokens = try container.decodeIfPresent(Int.self, forKey: .outputTokens)
        let inputTokens = try container.decodeIfPresent(Int.self, forKey: .inputTokens)
        for (key, tokens) in [(CodingKeys.outputTokens, outputTokens), (.inputTokens, inputTokens)] {
            guard (tokens ?? 0) >= 0 else {
                throw DecodingError.dataCorruptedError(
                    forKey: key, in: container, debugDescription: "token counts cannot be negative")
            }
        }
        self.init(
            text: try container.decodeIfPresent(String.self, forKey: .text),
            latency: latency,
            outputTokens: outputTokens,
            inputTokens: inputTokens,
            failure: try container.decodeIfPresent(GenerationFailure.self, forKey: .failure)
        )
    }
}

/// Why the model did not answer, mapped from the framework's error types.
public struct GenerationFailure: Sendable, Equatable, Codable {
    public var kind: Kind
    public var message: String

    public init(kind: Kind, message: String) {
        self.kind = kind
        self.message = message
    }

    public enum Kind: String, Sendable, Equatable, Codable, CaseIterable {
        /// The guardrails flagged the prompt or the response.
        case guardrailViolation
        /// The model declined to answer.
        case refusal
        case contextWindowExceeded
        case unsupportedLanguageOrLocale
        case unsupportedGuide
        case decodingFailure
        case assetsUnavailable
        case rateLimited
        case concurrentRequests
        case timeout
        /// Apple Intelligence is off, not ready, or the device is not eligible.
        case modelUnavailable
        case other
    }

    /// A guardrail violation or a refusal: what `refusal: true` expects.
    public var isDecline: Bool {
        kind == .guardrailViolation || kind == .refusal
    }
}
