import Foundation
import Yams

/// Checks, scalars and JSON values: the leaves of a suite.
extension NodeReader {
    // MARK: Assertions

    static let assertionKinds: Set<String> = [
        "contains", "containsAny", "notContains", "equals", "oneOf", "matches", "notMatches", "minLength",
        "maxLength", "atLeast", "atMost", "maxLatency", "maxOutputTokens", "refusal",
    ]
    static let textKinds: Set<String> = ["contains", "containsAny", "notContains", "equals", "oneOf"]
    static let wholeResponseKinds: Set<String> = ["maxLatency", "maxOutputTokens", "refusal"]

    func assertion(_ node: Node, context: String, hasSchema: Bool) throws -> Assertion {
        let entries = try mapping(
            node,
            "\(context) check",
            allowed: Self.assertionKinds.union(["path", "ignoreCase"])
        )
        let kinds = entries.keys.filter { Self.assertionKinds.contains($0) }.sorted()
        guard kinds.count == 1, let kindName = kinds.first, let valueNode = entries[kindName] else {
            let found = kinds.isEmpty ? "none" : kinds.joined(separator: ", ")
            throw error(
                node,
                "\(context): each check needs exactly one of \(Self.assertionKinds.sorted().joined(separator: ", ")) (found \(found))"
            )
        }
        var path: [String]?
        if let pathNode = entries["path"] {
            guard !Self.wholeResponseKinds.contains(kindName) else {
                throw error(pathNode, "\(context): `\(kindName)` applies to the whole response and takes no `path`")
            }
            guard hasSchema else {
                throw error(pathNode, "\(context): `path` reads structured output; add a `schema` to the case")
            }
            let text = try string(pathNode, "path")
            let steps = text.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
            guard !text.isEmpty, !steps.contains(where: \.isEmpty), steps.count <= JSONSchema.maximumDepth else {
                throw error(pathNode, "\(context): `path` must be dot-separated names such as `items.0.title`")
            }
            path = steps
        }
        var ignoreCase = false
        if let ignoreNode = entries["ignoreCase"] {
            guard Self.textKinds.contains(kindName) else {
                throw error(
                    ignoreNode,
                    "\(context): `ignoreCase` only applies to \(Self.textKinds.sorted().joined(separator: ", "))")
            }
            ignoreCase = try bool(ignoreNode, "ignoreCase")
        }
        let kind = try assertionKind(kindName, valueNode, context: context)
        return Assertion(kind, path: path, ignoreCase: ignoreCase)
    }

    func assertionKind(_ name: String, _ node: Node, context: String) throws -> Assertion.Kind {
        switch name {
        case "contains": return .contains(try strings(node, name))
        case "containsAny": return .containsAny(try strings(node, name))
        case "notContains": return .notContains(try strings(node, name))
        case "equals": return .equals(try json(node))
        case "oneOf":
            guard case .sequence(let items) = node, !items.isEmpty else {
                throw error(node, "\(context): `oneOf` must be a non-empty list")
            }
            return .oneOf(try items.map { try json($0) })
        case "matches": return .matches(try pattern(node, name))
        case "notMatches": return .notMatches(try pattern(node, name))
        case "minLength": return .minLength(try integer(node, name, in: 0...10_000_000))
        case "maxLength": return .maxLength(try integer(node, name, in: 0...10_000_000))
        case "atLeast": return .atLeast(try number(node, name))
        case "atMost": return .atMost(try number(node, name))
        case "maxLatency": return .maxLatency(try duration(node, name))
        case "maxOutputTokens": return .maxOutputTokens(try integer(node, name, in: 1...10_000_000))
        default: return .refusal(try bool(node, name))
        }
    }

    // MARK: Scalars

    func mapping(_ node: Node, _ context: String, allowed: Set<String>) throws -> [String: Node] {
        try visit(node)
        guard case .mapping(let mapping) = node else {
            throw error(node, "\(context) must be a mapping of `key: value` lines")
        }
        var result: [String: Node] = [:]
        for (keyNode, value) in mapping {
            try visit(keyNode)
            guard case .scalar(let key) = keyNode else {
                throw error(keyNode, "\(context): keys must be plain names")
            }
            guard allowed.contains(key.string) else {
                var message = "\(context): unknown key `\(key.string)`"
                if let guess = Spelling.suggestion(for: key.string, from: allowed) {
                    message += "; did you mean `\(guess)`?"
                } else {
                    message += "; expected one of \(allowed.sorted().joined(separator: ", "))"
                }
                throw error(keyNode, message)
            }
            result[key.string] = value
        }
        return result
    }

    func string(_ node: Node, _ key: String) throws -> String {
        try visit(node)
        guard case .scalar(let scalar) = node else {
            throw error(node, "`\(key)` must be text")
        }
        return scalar.string
    }

    /// The texts of `contains`, `containsAny` and `notContains`. Empty text is refused: every
    /// answer contains it, so the check would pass (or fail) without looking at the answer.
    func strings(_ node: Node, _ key: String) throws -> [String] {
        try visit(node)
        let items: [Node]
        if case .sequence(let sequence) = node {
            guard !sequence.isEmpty else { throw error(node, "`\(key)` must not be an empty list") }
            items = Array(sequence)
        } else {
            items = [node]
        }
        return try items.map { item in
            let text = try string(item, key)
            guard !text.isEmpty else {
                throw error(item, "`\(key)` must not hold empty text, which every answer contains")
            }
            return text
        }
    }

    func identifier(_ node: Node, _ key: String) throws -> String {
        let text = try string(node, key)
        let allowed = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
        guard !text.isEmpty, text.count <= 64, !text.hasPrefix("."), text.allSatisfy(allowed.contains) else {
            throw error(node, "`\(key)` must be 1–64 letters, digits, `-`, `_` or `.`, not starting with `.`")
        }
        return text
    }

    func number(_ node: Node, _ key: String) throws -> Double {
        let text = try string(node, key)
        guard case .scalar(let scalar) = node, scalar.style == .plain || scalar.style == .any,
            let value = Double(text), value.isFinite
        else {
            throw error(node, "`\(key)` must be a number")
        }
        return value
    }

    func integer(_ node: Node, _ key: String, in range: ClosedRange<Int>) throws -> Int {
        let text = try string(node, key)
        guard case .scalar(let scalar) = node, scalar.style == .plain || scalar.style == .any,
            let value = Int(text)
        else {
            throw error(node, "`\(key)` must be a whole number")
        }
        guard range.contains(value) else {
            throw error(node, "`\(key)` must be between \(range.lowerBound) and \(range.upperBound)")
        }
        return value
    }

    func bool(_ node: Node, _ key: String) throws -> Bool {
        switch try string(node, key) {
        case "true": return true
        case "false": return false
        default: throw error(node, "`\(key)` must be true or false")
        }
    }

    /// `0.8` or `80%`.
    func share(_ node: Node, _ key: String) throws -> Double {
        let text = try string(node, key).trimmingCharacters(in: .whitespaces)
        let value: Double?
        if text.hasSuffix("%") {
            value = Double(text.dropLast().trimmingCharacters(in: .whitespaces)).map { $0 / 100 }
        } else {
            value = Double(text)
        }
        guard let value, value >= 0, value <= 1 else {
            throw error(node, "`\(key)` must be a share between 0 and 1, or a percentage such as 80%")
        }
        return value
    }

    /// `2`, `2.5s`, `800ms`: seconds unless a unit is given; at most ``Generation/maximumWait``,
    /// the longest `--timeout`, since a generation never waits longer.
    func duration(_ node: Node, _ key: String) throws -> Double {
        let text = try string(node, key).trimmingCharacters(in: .whitespaces).lowercased()
        var number = text
        var scale = 1.0
        if text.hasSuffix("ms") {
            number = String(text.dropLast(2))
            scale = 0.001
        } else if text.hasSuffix("s") {
            number = String(text.dropLast())
        }
        guard let value = Double(number.trimmingCharacters(in: .whitespaces)), value.isFinite, value > 0 else {
            throw error(node, "`\(key)` must be a duration such as 2s, 1.5s or 800ms")
        }
        let seconds = value * scale
        guard seconds <= Generation.maximumWait else {
            throw error(
                node, "`\(key)` must be at most \(Format.number(Generation.maximumWait))s, the longest --timeout")
        }
        return seconds
    }

    func pattern(_ node: Node, _ key: String) throws -> String {
        let text = try string(node, key)
        guard !text.isEmpty else { throw error(node, "`\(key)` must not be empty") }
        do {
            _ = try Regex(text)
        } catch {
            throw self.error(node, "`\(key)` is not a valid regular expression: \(text)")
        }
        return text
    }

    /// Converts a YAML value to JSON: plain scalars become numbers, booleans or null when they
    /// read as one; quoted scalars stay text.
    func json(_ node: Node, depth: Int = 0) throws -> JSONValue {
        try visit(node)
        guard depth <= JSONValue.maximumDepth else {
            throw error(node, "nests deeper than \(JSONValue.maximumDepth) levels")
        }
        switch node {
        case .scalar(let scalar):
            guard scalar.style == .plain || scalar.style == .any else { return .string(scalar.string) }
            switch scalar.string {
            case "true": return .bool(true)
            case "false": return .bool(false)
            case "null", "~": return .null
            default:
                if let value = Double(scalar.string), value.isFinite,
                    scalar.string.first.map({ $0.isNumber || $0 == "-" || $0 == "+" || $0 == "." }) == true
                {
                    return .number(value)
                }
                return .string(scalar.string)
            }
        case .sequence(let sequence):
            return .array(try sequence.map { try json($0, depth: depth + 1) })
        case .mapping(let mapping):
            var object: [String: JSONValue] = [:]
            for (keyNode, value) in mapping {
                guard case .scalar(let key) = keyNode else {
                    throw error(keyNode, "keys must be plain names")
                }
                object[key.string] = try json(value, depth: depth + 1)
            }
            return .object(object)
        case .alias:
            throw error(node, "YAML aliases are not supported")
        }
    }
}
