import Foundation

/// Maps Foundation Models errors to ``GenerationFailure/Kind``.
///
/// macOS 27 replaced `LanguageModelSession.GenerationError` with `LanguageModelError`,
/// `LanguageModelSession.Error` and `SystemLanguageModel.Error`. Which one arrives depends on
/// the SDK fmdrift was built with and the OS it runs on, so errors are classified by their case
/// name, which both generations of the API share, instead of by type. Only errors from the
/// FoundationModels module are classified this way.
public enum ErrorClassifier {
    public static func failure(from error: any Error) -> GenerationFailure {
        let typeName = String(reflecting: type(of: error))
        let message = Self.message(of: error)
        if error is CancellationError {
            return GenerationFailure(kind: .timeout, message: "the generation was cancelled")
        }
        guard typeName.hasPrefix("FoundationModels.") else {
            return GenerationFailure(kind: .other, message: message)
        }
        if typeName.hasSuffix("ParsingError") {
            return GenerationFailure(kind: .decodingFailure, message: message)
        }
        return GenerationFailure(kind: kind(forCase: caseName(of: error)), message: message)
    }

    /// The enum case of an error: the label of its payload, or its description when it has none.
    static func caseName(of error: any Error) -> String {
        if let label = Mirror(reflecting: error).children.first?.label {
            return label
        }
        let text = String(describing: error)
        return String(text.prefix { $0.isLetter || $0.isNumber })
    }

    public static func kind(forCase name: String) -> GenerationFailure.Kind {
        switch name {
        case "guardrailViolation": .guardrailViolation
        case "refusal": .refusal
        case "exceededContextWindowSize", "contextSizeExceeded": .contextWindowExceeded
        case "unsupportedLanguageOrLocale": .unsupportedLanguageOrLocale
        case "unsupportedGuide", "unsupportedGenerationGuide": .unsupportedGuide
        case "decodingFailure": .decodingFailure
        case "assetsUnavailable": .assetsUnavailable
        case "rateLimited": .rateLimited
        case "concurrentRequests": .concurrentRequests
        case "timeout": .timeout
        default: .other
        }
    }

    /// A one-line message of at most 300 characters.
    static func message(of error: any Error) -> String {
        let text = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        return Excerpt.of(text, limit: 300)
    }
}
