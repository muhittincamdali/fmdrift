import Foundation

/// The part of JSON Schema that maps onto Foundation Models guided generation.
///
/// Each keyword here has a counterpart in `DynamicGenerationSchema` or `GenerationGuide`, so a
/// suite never describes a structure the model cannot be asked for. Anything else is rejected
/// when the suite is read, with the list of supported keywords.
public indirect enum JSONSchema: Sendable, Equatable {
    case object(properties: [Property], description: String?)
    case string(enumValues: [String]?, pattern: String?, description: String?)
    case integer(minimum: Int?, maximum: Int?, description: String?)
    case number(minimum: Double?, maximum: Double?, description: String?)
    case boolean(description: String?)
    case array(items: JSONSchema, minItems: Int?, maxItems: Int?, description: String?)

    public struct Property: Sendable, Equatable {
        public var name: String
        public var schema: JSONSchema
        public var isRequired: Bool

        public init(name: String, schema: JSONSchema, isRequired: Bool) {
            self.name = name
            self.schema = schema
            self.isRequired = isRequired
        }
    }

    /// Nesting deeper than this is rejected; guided generation schemas stay shallow in practice.
    public static let maximumDepth = 16

    static let keywords: [String: Set<String>] = [
        "object": ["type", "description", "title", "properties", "required"],
        "string": ["type", "description", "title", "enum", "pattern"],
        "integer": ["type", "description", "title", "minimum", "maximum"],
        "number": ["type", "description", "title", "minimum", "maximum"],
        "boolean": ["type", "description", "title"],
        "array": ["type", "description", "title", "items", "minItems", "maxItems"],
    ]

    /// Reads a schema written as JSON (or YAML converted to JSON). `location` names the place in
    /// the suite for error messages, such as `cases[2].schema`.
    public static func parse(_ value: JSONValue, at location: String, depth: Int = 0) throws(SchemaError)
        -> JSONSchema
    {
        guard depth < maximumDepth else {
            throw SchemaError(location: location, message: "nests deeper than \(maximumDepth) levels")
        }
        guard case .object(let object) = value else {
            throw SchemaError(location: location, message: "must be a mapping with a `type`")
        }
        guard case .string(let type)? = object["type"] else {
            throw SchemaError(
                location: location,
                message: "needs a `type`: object, string, integer, number, boolean or array"
            )
        }
        guard let allowed = keywords[type] else {
            throw SchemaError(
                location: location,
                message: "type `\(type)` is not supported; use object, string, integer, number, boolean or array"
            )
        }
        for key in object.keys.sorted() where !allowed.contains(key) {
            throw SchemaError(
                location: location,
                message:
                    "`\(key)` is not supported for type \(type); supported: \(allowed.sorted().joined(separator: ", "))"
            )
        }
        let description = try optionalString(object["description"], "description", at: location)

        switch type {
        case "object":
            return try parseObject(object, description: description, at: location, depth: depth)
        case "string":
            var enumValues: [String]?
            if let raw = object["enum"] {
                guard case .array(let items) = raw, !items.isEmpty else {
                    throw SchemaError(location: location, message: "`enum` must be a non-empty list of strings")
                }
                enumValues = try items.map { item throws(SchemaError) in
                    guard case .string(let text) = item else {
                        throw SchemaError(location: location, message: "`enum` may only hold strings")
                    }
                    return text
                }
            }
            let pattern = try optionalString(object["pattern"], "pattern", at: location)
            if let pattern {
                do {
                    _ = try Regex(pattern)
                } catch {
                    throw SchemaError(location: location, message: "`pattern` is not a valid regular expression")
                }
            }
            if enumValues != nil, pattern != nil {
                throw SchemaError(location: location, message: "use either `enum` or `pattern`, not both")
            }
            return .string(enumValues: enumValues, pattern: pattern, description: description)
        case "integer":
            let minimum = try optionalInteger(object["minimum"], "minimum", at: location)
            let maximum = try optionalInteger(object["maximum"], "maximum", at: location)
            if let minimum, let maximum, minimum > maximum {
                throw SchemaError(location: location, message: "`minimum` is greater than `maximum`")
            }
            return .integer(minimum: minimum, maximum: maximum, description: description)
        case "number":
            let minimum = try optionalNumber(object["minimum"], "minimum", at: location)
            let maximum = try optionalNumber(object["maximum"], "maximum", at: location)
            if let minimum, let maximum, minimum > maximum {
                throw SchemaError(location: location, message: "`minimum` is greater than `maximum`")
            }
            return .number(minimum: minimum, maximum: maximum, description: description)
        case "boolean":
            return .boolean(description: description)
        default:
            guard let items = object["items"] else {
                throw SchemaError(location: location, message: "an array needs `items`")
            }
            let itemSchema = try parse(items, at: "\(location).items", depth: depth + 1)
            let minItems = try optionalInteger(object["minItems"], "minItems", at: location)
            let maxItems = try optionalInteger(object["maxItems"], "maxItems", at: location)
            if let minItems, minItems < 0 {
                throw SchemaError(location: location, message: "`minItems` cannot be negative")
            }
            if let maxItems, maxItems < 0 {
                throw SchemaError(location: location, message: "`maxItems` cannot be negative")
            }
            if let minItems, let maxItems, minItems > maxItems {
                throw SchemaError(location: location, message: "`minItems` is greater than `maxItems`")
            }
            return .array(items: itemSchema, minItems: minItems, maxItems: maxItems, description: description)
        }
    }

    private static func parseObject(
        _ object: [String: JSONValue],
        description: String?,
        at location: String,
        depth: Int
    ) throws(SchemaError) -> JSONSchema {
        guard case .object(let rawProperties)? = object["properties"], !rawProperties.isEmpty else {
            throw SchemaError(location: location, message: "an object needs at least one entry in `properties`")
        }
        var required: [String] = []
        if let raw = object["required"] {
            guard case .array(let items) = raw else {
                throw SchemaError(location: location, message: "`required` must be a list of property names")
            }
            for item in items {
                guard case .string(let name) = item else {
                    throw SchemaError(location: location, message: "`required` must be a list of property names")
                }
                guard rawProperties[name] != nil else {
                    throw SchemaError(
                        location: location, message: "`required` names `\(name)`, which is not a property")
                }
                required.append(name)
            }
        }
        var properties: [Property] = []
        for name in rawProperties.keys.sorted() {
            guard let raw = rawProperties[name] else { continue }
            let schema = try parse(raw, at: "\(location).properties.\(name)", depth: depth + 1)
            properties.append(Property(name: name, schema: schema, isRequired: required.contains(name)))
        }
        return .object(properties: properties, description: description)
    }

    private static func optionalString(_ value: JSONValue?, _ key: String, at location: String) throws(SchemaError)
        -> String?
    {
        guard let value else { return nil }
        guard case .string(let text) = value else {
            throw SchemaError(location: location, message: "`\(key)` must be text")
        }
        return text
    }

    private static func optionalNumber(_ value: JSONValue?, _ key: String, at location: String) throws(SchemaError)
        -> Double?
    {
        guard let value else { return nil }
        guard case .number(let number) = value, number.isFinite else {
            throw SchemaError(location: location, message: "`\(key)` must be a number")
        }
        return number
    }

    private static func optionalInteger(_ value: JSONValue?, _ key: String, at location: String) throws(SchemaError)
        -> Int?
    {
        guard let number = try optionalNumber(value, key, at: location) else { return nil }
        guard number.rounded() == number, abs(number) <= Double(Int32.max) else {
            throw SchemaError(location: location, message: "`\(key)` must be a whole number")
        }
        return Int(number)
    }

    /// The schema as JSON with sorted keys; part of a case's fingerprint and of snapshots.
    public var canonicalJSON: String { jsonValue.compactJSON }

    /// The schema written back as JSON Schema.
    public var jsonValue: JSONValue {
        var object: [String: JSONValue] = [:]
        switch self {
        case .object(let properties, let description):
            object["type"] = .string("object")
            object["description"] = description.map(JSONValue.string)
            object["properties"] = .object(
                Dictionary(uniqueKeysWithValues: properties.map { ($0.name, $0.schema.jsonValue) })
            )
            let required = properties.filter(\.isRequired).map { JSONValue.string($0.name) }
            if !required.isEmpty { object["required"] = .array(required) }
        case .string(let enumValues, let pattern, let description):
            object["type"] = .string("string")
            object["description"] = description.map(JSONValue.string)
            object["enum"] = enumValues.map { .array($0.map(JSONValue.string)) }
            object["pattern"] = pattern.map(JSONValue.string)
        case .integer(let minimum, let maximum, let description):
            object["type"] = .string("integer")
            object["description"] = description.map(JSONValue.string)
            object["minimum"] = minimum.map { .number(Double($0)) }
            object["maximum"] = maximum.map { .number(Double($0)) }
        case .number(let minimum, let maximum, let description):
            object["type"] = .string("number")
            object["description"] = description.map(JSONValue.string)
            object["minimum"] = minimum.map(JSONValue.number)
            object["maximum"] = maximum.map(JSONValue.number)
        case .boolean(let description):
            object["type"] = .string("boolean")
            object["description"] = description.map(JSONValue.string)
        case .array(let items, let minItems, let maxItems, let description):
            object["type"] = .string("array")
            object["description"] = description.map(JSONValue.string)
            object["items"] = items.jsonValue
            object["minItems"] = minItems.map { .number(Double($0)) }
            object["maxItems"] = maxItems.map { .number(Double($0)) }
        }
        return .object(object)
    }
}

/// A schema keyword that fmdrift cannot turn into a guided generation schema.
public struct SchemaError: Error, Equatable, CustomStringConvertible {
    public var location: String
    public var message: String

    public var description: String { "\(location): \(message)" }
}
