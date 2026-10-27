import CryptoKit
import Foundation

/// One check on a response, written as an entry of a case's `expect` list.
public struct Assertion: Sendable, Equatable {
    public var kind: Kind
    /// Dot path into a structured response (`items.0.name`); nil checks the whole output.
    public var path: [String]?
    /// Compare text without regard to case (`contains`, `notContains`, `equals`, `oneOf`).
    public var ignoreCase: Bool

    public init(_ kind: Kind, path: [String]? = nil, ignoreCase: Bool = false) {
        self.kind = kind
        self.path = path
        self.ignoreCase = ignoreCase
    }

    public enum Kind: Sendable, Equatable {
        /// Every string must appear.
        case contains([String])
        /// At least one string must appear.
        case containsAny([String])
        /// None of the strings may appear.
        case notContains([String])
        /// The text (or the value at `path`) equals this value.
        case equals(JSONValue)
        /// The text (or the value at `path`) equals one of these values.
        case oneOf([JSONValue])
        /// The regular expression matches somewhere in the text.
        case matches(String)
        /// The regular expression matches nowhere in the text.
        case notMatches(String)
        /// Characters of the text, or elements when `path` points at an array.
        case minLength(Int)
        case maxLength(Int)
        /// The number at `path` is at least / at most this value.
        case atLeast(Double)
        case atMost(Double)
        /// Seconds from sending the prompt to the complete response.
        case maxLatency(Double)
        /// Tokens in the response.
        case maxOutputTokens(Int)
        /// True: the model must decline (a guardrail violation or a refusal). False: it must answer.
        case refusal(Bool)
    }

    /// The assertion as it reads in a report, close to how it is written in the suite.
    public var label: String {
        let prefix = path.map { "\($0.joined(separator: ".")) " } ?? ""
        let caseNote = ignoreCase ? " (ignoring case)" : ""
        switch kind {
        case .contains(let values): return "\(prefix)contains \(Self.list(values))\(caseNote)"
        case .containsAny(let values): return "\(prefix)contains any of \(Self.list(values))\(caseNote)"
        case .notContains(let values): return "\(prefix)does not contain \(Self.list(values))\(caseNote)"
        case .equals(let value): return "\(prefix)equals \(value.compactJSON)\(caseNote)"
        case .oneOf(let values):
            return "\(prefix)is one of \(values.map(\.compactJSON).joined(separator: ", "))\(caseNote)"
        case .matches(let pattern): return "\(prefix)matches /\(pattern)/"
        case .notMatches(let pattern): return "\(prefix)does not match /\(pattern)/"
        case .minLength(let count): return "\(prefix)length ≥ \(count)"
        case .maxLength(let count): return "\(prefix)length ≤ \(count)"
        case .atLeast(let value): return "\(prefix)≥ \(Format.number(value))"
        case .atMost(let value): return "\(prefix)≤ \(Format.number(value))"
        case .maxLatency(let seconds): return "latency ≤ \(Format.duration(seconds))"
        case .maxOutputTokens(let count): return "output tokens ≤ \(count)"
        case .refusal(let expected): return expected ? "model declines" : "model answers"
        }
    }

    private static func list(_ values: [String]) -> String {
        values.map { "\"\($0)\"" }.joined(separator: ", ")
    }
}

enum SHA256Digest {
    static func hex(of text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
