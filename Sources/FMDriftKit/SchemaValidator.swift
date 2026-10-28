import Foundation

/// Checks a structured response against the case schema.
///
/// Guided generation already constrains the model to the schema, so on the system model this
/// mostly confirms the framework did its job. It matters for replayed snapshots (the schema may
/// have changed since they were recorded) and for constraints a provider does not enforce.
public enum SchemaValidator {
    /// Problems found, each prefixed with the path where it occurs; empty when the value conforms.
    public static func problems(in value: JSONValue, against schema: JSONSchema) -> [String] {
        var problems: [String] = []
        check(value, schema, path: "$", problems: &problems)
        return problems
    }

    private static func check(_ value: JSONValue, _ schema: JSONSchema, path: String, problems: inout [String]) {
        // Keep reports short when a whole subtree is wrong.
        guard problems.count < 20 else { return }
        switch schema {
        case .object(let properties, _):
            guard case .object(let object) = value else {
                problems.append("\(path): expected an object, got \(value.typeName)")
                return
            }
            for property in properties {
                if let child = object[property.name] {
                    if child == .null, !property.isRequired { continue }
                    check(child, property.schema, path: "\(path).\(property.name)", problems: &problems)
                } else if property.isRequired {
                    problems.append("\(path): missing required property `\(property.name)`")
                }
            }
            let known = Set(properties.map(\.name))
            for key in object.keys.sorted() where !known.contains(key) {
                problems.append("\(path): unexpected property `\(key)`")
            }
        case .string(let enumValues, let pattern, _):
            guard case .string(let text) = value else {
                problems.append("\(path): expected a string, got \(value.typeName)")
                return
            }
            if let enumValues, !enumValues.contains(text) {
                let allowed = enumValues.map { "\"\($0)\"" }.joined(separator: ", ")
                problems.append("\(path): \"\(Excerpt.of(text))\" is not one of \(allowed)")
            }
            if let pattern {
                switch PatternMatch.run(pattern, in: text) {
                case .matched: break
                case .notMatched: problems.append("\(path): \"\(Excerpt.of(text))\" does not match /\(pattern)/")
                case .timedOut: problems.append("\(path): \(PatternMatch.timedOutDetail(pattern))")
                }
            }
        case .integer(let minimum, let maximum, _):
            guard case .number(let number) = value, number.rounded() == number else {
                problems.append("\(path): expected an integer, got \(value.typeName)")
                return
            }
            checkBounds(number, minimum.map(Double.init), maximum.map(Double.init), path: path, problems: &problems)
        case .number(let minimum, let maximum, _):
            guard case .number(let number) = value else {
                problems.append("\(path): expected a number, got \(value.typeName)")
                return
            }
            checkBounds(number, minimum, maximum, path: path, problems: &problems)
        case .boolean:
            guard case .bool = value else {
                problems.append("\(path): expected a boolean, got \(value.typeName)")
                return
            }
        case .array(let items, let minItems, let maxItems, _):
            guard case .array(let elements) = value else {
                problems.append("\(path): expected an array, got \(value.typeName)")
                return
            }
            if let minItems, elements.count < minItems {
                problems.append("\(path): \(elements.count) items, expected at least \(minItems)")
            }
            if let maxItems, elements.count > maxItems {
                problems.append("\(path): \(elements.count) items, expected at most \(maxItems)")
            }
            for (index, element) in elements.enumerated() {
                check(element, items, path: "\(path)[\(index)]", problems: &problems)
            }
        }
    }

    private static func checkBounds(
        _ number: Double,
        _ minimum: Double?,
        _ maximum: Double?,
        path: String,
        problems: inout [String]
    ) {
        if let minimum, number < minimum {
            problems.append("\(path): \(Format.number(number)) is below the minimum \(Format.number(minimum))")
        }
        if let maximum, number > maximum {
            problems.append("\(path): \(Format.number(number)) is above the maximum \(Format.number(maximum))")
        }
    }
}

/// Shortens text for messages: one line, at most `limit` characters.
public enum Excerpt {
    public static func of(_ text: String, limit: Int = 60) -> String {
        let flattened = text.replacingOccurrences(of: "\r\n", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
        guard flattened.count > limit else { return flattened }
        return String(flattened.prefix(limit - 1)) + "…"
    }
}
