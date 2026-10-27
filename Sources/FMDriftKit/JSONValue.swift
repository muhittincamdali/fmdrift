import Foundation

/// A JSON value: what a structured response decodes to, and what `equals` and `oneOf` compare
/// against when an assertion has a `path`.
public enum JSONValue: Sendable, Hashable, Codable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    /// Nesting deeper than this is rejected when text is parsed, so a hostile snapshot or model
    /// output cannot exhaust the stack.
    public static let maximumDepth = 64

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Not a JSON value")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }

    /// Parses JSON text. Returns nil for text that is not JSON or nests deeper than
    /// `maximumDepth`.
    public static func parse(_ text: String) -> JSONValue? {
        guard let data = text.data(using: .utf8), nestingDepth(of: data) <= maximumDepth else {
            return nil
        }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        else { return nil }
        return JSONValue(foundation: object)
    }

    init?(foundation object: Any) {
        switch object {
        case is NSNull:
            self = .null
        case let number as NSNumber:
            // JSONSerialization returns booleans as NSNumber; CFBoolean tells them apart.
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                self = .bool(number.boolValue)
            } else {
                self = .number(number.doubleValue)
            }
        case let string as String:
            self = .string(string)
        case let array as [Any]:
            var values: [JSONValue] = []
            values.reserveCapacity(array.count)
            for element in array {
                guard let value = JSONValue(foundation: element) else { return nil }
                values.append(value)
            }
            self = .array(values)
        case let dictionary as [String: Any]:
            var values: [String: JSONValue] = [:]
            for (key, element) in dictionary {
                guard let value = JSONValue(foundation: element) else { return nil }
                values[key] = value
            }
            self = .object(values)
        default:
            return nil
        }
    }

    /// Counts the deepest bracket nesting without parsing, skipping brackets inside strings.
    static func nestingDepth(of data: Data) -> Int {
        var depth = 0
        var deepest = 0
        var inString = false
        var escaped = false
        for byte in data {
            if inString {
                if escaped {
                    escaped = false
                } else if byte == UInt8(ascii: "\\") {
                    escaped = true
                } else if byte == UInt8(ascii: "\"") {
                    inString = false
                }
                continue
            }
            switch byte {
            case UInt8(ascii: "\""): inString = true
            case UInt8(ascii: "["), UInt8(ascii: "{"):
                depth += 1
                deepest = max(deepest, depth)
            case UInt8(ascii: "]"), UInt8(ascii: "}"): depth -= 1
            default: break
            }
        }
        return deepest
    }

    /// The value at a dot path such as `items.0.name`; nil when a step does not exist.
    public func value(at path: [String]) -> JSONValue? {
        var current = self
        for step in path {
            switch current {
            case .object(let object):
                guard let next = object[step] else { return nil }
                current = next
            case .array(let array):
                guard let index = Int(step), array.indices.contains(index) else { return nil }
                current = array[index]
            default:
                return nil
            }
        }
        return current
    }

    /// The text an assertion reads: a string as it is, anything else as compact JSON.
    public var text: String {
        if case .string(let value) = self { return value }
        return compactJSON
    }

    /// Compact JSON with sorted keys, used in messages and for comparing values.
    public var compactJSON: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(self), let text = String(data: data, encoding: .utf8) else {
            return ""
        }
        return text
    }

    /// Short type name for messages.
    public var typeName: String {
        switch self {
        case .null: "null"
        case .bool: "boolean"
        case .number(let value): value.rounded() == value && abs(value) < 9e15 ? "integer" : "number"
        case .string: "string"
        case .array: "array"
        case .object: "object"
        }
    }
}
