import Foundation

/// The outcome of one check on one response.
public struct CheckResult: Sendable, Equatable, Codable {
    public enum Status: String, Sendable, Codable {
        case passed
        case failed
        /// The check could not be made, for example a token limit when the OS cannot count tokens.
        case skipped
    }

    public var label: String
    public var status: Status
    /// What was found, for a failed or skipped check.
    public var detail: String?

    public init(label: String, status: Status, detail: String? = nil) {
        self.label = label
        self.status = status
        self.detail = detail
    }
}

/// Applies a case's checks to one response.
public enum Evaluator {
    /// Label of the check added when a case has a schema.
    public static let schemaLabel = "matches the schema"
    /// Label of the check added when the model failed and the case does not say it may decline.
    public static let answerLabel = "model answers"

    public static func evaluate(_ generation: Generation, for testCase: TestCase) -> [CheckResult] {
        evaluate(generation, for: testCase, patterns: PatternBudget())
    }

    /// Checks one response, charging regular expressions to the run's `patterns` budget.
    static func evaluate(_ generation: Generation, for testCase: TestCase, patterns: PatternBudget) -> [CheckResult] {
        var results: [CheckResult] = []
        let expectsRefusal = testCase.assertions.contains { $0.kind == .refusal(true) }
        let mentionsRefusal = testCase.assertions.contains {
            if case .refusal = $0.kind { return true }
            return false
        }

        if let failure = generation.failure, !mentionsRefusal {
            results.append(
                CheckResult(label: answerLabel, status: .failed, detail: "\(failure.kind.rawValue): \(failure.message)")
            )
        }

        var structured: JSONValue?
        if let schema = testCase.schema, let text = generation.text {
            if let value = JSONValue.parse(text) {
                structured = value
                let problems = SchemaValidator.problems(in: value, against: schema, patterns: patterns)
                results.append(
                    CheckResult(
                        label: schemaLabel,
                        status: problems.isEmpty ? .passed : .failed,
                        detail: problems.isEmpty ? nil : problems.joined(separator: "; ")
                    )
                )
            } else {
                results.append(
                    CheckResult(label: schemaLabel, status: .failed, detail: "the response is not JSON")
                )
            }
        }

        for assertion in testCase.assertions {
            results.append(
                check(
                    assertion,
                    generation: generation,
                    structured: structured,
                    expectsRefusal: expectsRefusal,
                    patterns: patterns
                )
            )
        }
        return results
    }

    static func check(
        _ assertion: Assertion,
        generation: Generation,
        structured: JSONValue?,
        expectsRefusal: Bool,
        patterns: PatternBudget
    ) -> CheckResult {
        let label = assertion.label
        func result(_ passed: Bool, _ detail: @autoclosure () -> String) -> CheckResult {
            CheckResult(label: label, status: passed ? .passed : .failed, detail: passed ? nil : detail())
        }

        switch assertion.kind {
        case .maxLatency(let limit):
            return result(generation.latency <= limit, "took \(Format.duration(generation.latency))")
        case .refusal(let expected):
            if let failure = generation.failure {
                if expected {
                    return result(failure.isDecline, "failed with \(failure.kind.rawValue) instead: \(failure.message)")
                }
                return result(false, "\(failure.kind.rawValue): \(failure.message)")
            }
            return result(!expected, "answered: \"\(Excerpt.of(generation.text ?? ""))\"")
        case .maxOutputTokens(let limit):
            if generation.failure != nil {
                return CheckResult(label: label, status: .skipped, detail: "no response")
            }
            guard let tokens = generation.outputTokens else {
                return CheckResult(label: label, status: .skipped, detail: "this OS does not report token counts")
            }
            return result(tokens <= limit, "\(tokens) tokens")
        default:
            break
        }

        // Content checks need a response.
        guard generation.failure == nil, let text = generation.text else {
            if expectsRefusal {
                return CheckResult(label: label, status: .skipped, detail: "the model declined, as expected")
            }
            return result(false, "no response")
        }

        let subject: JSONValue
        if let path = assertion.path {
            guard let structured else {
                return result(false, "the response is not JSON")
            }
            guard let value = structured.value(at: path) else {
                return result(false, "no value at `\(path.joined(separator: "."))`")
            }
            subject = value
        } else {
            subject = .string(text)
        }
        return content(
            assertion,
            subject: subject,
            isWholeText: assertion.path == nil,
            patterns: patterns,
            result: result
        )
    }

    private static func content(
        _ assertion: Assertion,
        subject: JSONValue,
        isWholeText: Bool,
        patterns: PatternBudget,
        result: (Bool, @autoclosure () -> String) -> CheckResult
    ) -> CheckResult {
        let ignoreCase = assertion.ignoreCase
        let text = subject.text
        let shown = "\"\(Excerpt.of(text))\""
        func normalized(_ value: String) -> String {
            ignoreCase ? value.lowercased() : value
        }
        func found(_ needle: String) -> Bool {
            text.range(of: needle, options: ignoreCase ? [.caseInsensitive] : []) != nil
        }
        func equal(_ expected: JSONValue) -> Bool {
            if isWholeText {
                return normalized(text.trimmingCharacters(in: .whitespacesAndNewlines)) == normalized(expected.text)
            }
            switch (subject, expected) {
            case (.string(let actual), .string(let wanted)):
                return normalized(actual) == normalized(wanted)
            default:
                return subject == expected
            }
        }

        switch assertion.kind {
        case .contains(let needles):
            let missing = needles.filter { !found($0) }
            return result(missing.isEmpty, "missing \(missing.map { "\"\($0)\"" }.joined(separator: ", ")) in \(shown)")
        case .containsAny(let needles):
            return result(needles.contains(where: found), "none found in \(shown)")
        case .notContains(let needles):
            let present = needles.filter(found)
            return result(present.isEmpty, "found \(present.map { "\"\($0)\"" }.joined(separator: ", ")) in \(shown)")
        case .equals(let expected):
            return result(equal(expected), "got \(isWholeText ? shown : subject.compactJSON)")
        case .oneOf(let options):
            return result(options.contains(where: equal), "got \(isWholeText ? shown : subject.compactJSON)")
        case .matches(let pattern):
            let outcome = PatternMatch.run(pattern, in: text, budget: patterns)
            if let detail = PatternMatch.detail(outcome, pattern: pattern) { return result(false, detail) }
            return result(outcome == .matched, "no match in \(shown)")
        case .notMatches(let pattern):
            let outcome = PatternMatch.run(pattern, in: text, budget: patterns)
            if let detail = PatternMatch.detail(outcome, pattern: pattern) { return result(false, detail) }
            return result(outcome == .notMatched, "matched in \(shown)")
        case .minLength(let count):
            let length = length(of: subject)
            return result(length >= count, "\(length) \(unit(of: subject))")
        case .maxLength(let count):
            let length = length(of: subject)
            return result(length <= count, "\(length) \(unit(of: subject))")
        case .atLeast(let bound):
            guard let number = number(subject) else { return result(false, "\(shown) is not a number") }
            return result(number >= bound, "got \(Format.number(number))")
        case .atMost(let bound):
            guard let number = number(subject) else { return result(false, "\(shown) is not a number") }
            return result(number <= bound, "got \(Format.number(number))")
        case .maxLatency, .maxOutputTokens, .refusal:
            return result(true, "")
        }
    }

    private static func length(of value: JSONValue) -> Int {
        if case .array(let elements) = value { return elements.count }
        return value.text.count
    }

    private static func unit(of value: JSONValue) -> String {
        if case .array = value { return "items" }
        return "characters"
    }

    private static func number(_ value: JSONValue) -> Double? {
        switch value {
        case .number(let number): return number
        case .string(let text):
            return Double(text.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isFinite ? $0 : nil }
        default: return nil
        }
    }
}
