import Foundation
import Testing

@testable import FMDriftKit

@Suite("JSON Schema subset")
struct JSONSchemaTests {
    private func parse(_ json: String) throws(SchemaError) -> JSONSchema {
        try JSONSchema.parse(JSONValue.parse(json) ?? .null, at: "schema")
    }

    @Test func readsANestedSchema() throws {
        let schema = try parse(
            """
            {"type": "object", "description": "A ticket", "required": ["sentiment", "tags"],
             "properties": {
               "sentiment": {"type": "string", "enum": ["positive", "neutral", "negative"]},
               "score": {"type": "integer", "minimum": 1, "maximum": 5},
               "confidence": {"type": "number", "minimum": 0, "maximum": 1},
               "urgent": {"type": "boolean"},
               "code": {"type": "string", "pattern": "^[A-Z]{3}-\\\\d+$"},
               "tags": {"type": "array", "items": {"type": "string"}, "minItems": 1, "maxItems": 3}
             }}
            """
        )
        guard case .object(let properties, let description) = schema else {
            Issue.record("not an object")
            return
        }
        #expect(description == "A ticket")
        #expect(properties.map(\.name) == ["code", "confidence", "score", "sentiment", "tags", "urgent"])
        #expect(properties.filter(\.isRequired).map(\.name) == ["sentiment", "tags"])
        #expect(
            properties[3].schema
                == .string(enumValues: ["positive", "neutral", "negative"], pattern: nil, description: nil)
        )
        #expect(properties[2].schema == .integer(minimum: 1, maximum: 5, description: nil))
        #expect(
            properties[4].schema
                == .array(
                    items: .string(enumValues: nil, pattern: nil, description: nil),
                    minItems: 1,
                    maxItems: 3,
                    description: nil
                )
        )
    }

    @Test func roundTripsThroughCanonicalJSON() throws {
        let text =
            #"{"properties":{"a":{"items":{"type":"boolean"},"maxItems":2,"type":"array"},"b":{"maximum":2.5,"type":"number"}},"required":["a"],"type":"object"}"#
        let schema = try parse(text)
        #expect(schema.canonicalJSON == text)
        #expect(try parse(schema.canonicalJSON) == schema)
    }

    @Test(arguments: [
        (#"[]"#, "schema: must be a mapping with a `type`"),
        (#"{"properties": {}}"#, "schema: needs a `type`: object, string, integer, number, boolean or array"),
        (
            #"{"type": "date"}"#,
            "schema: type `date` is not supported; use object, string, integer, number, boolean or array"
        ),
        (
            #"{"type": "string", "format": "email"}"#,
            "schema: `format` is not supported for type string; supported: description, enum, pattern, title, type"
        ),
        (#"{"type": "object", "properties": {}}"#, "schema: an object needs at least one entry in `properties`"),
        (
            #"{"type": "object", "properties": {"a": {"type": "string"}}, "required": ["b"]}"#,
            "schema: `required` names `b`, which is not a property"
        ),
        (#"{"type": "string", "enum": []}"#, "schema: `enum` must be a non-empty list of strings"),
        (#"{"type": "string", "enum": [1]}"#, "schema: `enum` may only hold strings"),
        (#"{"type": "string", "pattern": "("}"#, "schema: `pattern` is not a valid regular expression"),
        (#"{"type": "string", "pattern": "a", "enum": ["a"]}"#, "schema: use either `enum` or `pattern`, not both"),
        (#"{"type": "integer", "minimum": 1.5}"#, "schema: `minimum` must be a whole number"),
        (#"{"type": "integer", "minimum": 5, "maximum": 1}"#, "schema: `minimum` is greater than `maximum`"),
        (#"{"type": "array"}"#, "schema: an array needs `items`"),
        (
            #"{"type": "array", "items": {"type": "string"}, "minItems": 3, "maxItems": 1}"#,
            "schema: `minItems` is greater than `maxItems`"
        ),
        (
            #"{"type": "array", "items": {"type": "nope"}}"#,
            "schema.items: type `nope` is not supported; use object, string, integer, number, boolean or array"
        ),
    ])
    func rejectsWhatGuidedGenerationCannotExpress(json: String, expected: String) {
        do {
            _ = try parse(json)
            Issue.record("expected an error")
        } catch {
            #expect(error.description == expected)
        }
    }

    @Test func limitsNesting() {
        var json = #"{"type": "string"}"#
        for _ in 0..<JSONSchema.maximumDepth {
            json = #"{"type": "array", "items": "# + json + "}"
        }
        do {
            _ = try parse(json)
            Issue.record("expected an error")
        } catch {
            #expect(error.message == "nests deeper than 16 levels")
        }
    }
}

@Suite("JSON values")
struct JSONValueTests {
    @Test func parsesAndReadsPaths() throws {
        let value = try #require(JSONValue.parse(#"{"items": [{"name": "a"}, {"name": "b", "n": 2}], "ok": true}"#))
        #expect(value.value(at: ["items", "1", "name"]) == .string("b"))
        #expect(value.value(at: ["items", "1", "n"]) == .number(2))
        #expect(value.value(at: ["ok"]) == .bool(true))
        #expect(value.value(at: ["items", "5"]) == nil)
        #expect(value.value(at: ["ok", "x"]) == nil)
        #expect(value.value(at: ["items", "x"]) == nil)
    }

    @Test func rejectsTextThatIsNotJSONOrTooDeep() {
        #expect(JSONValue.parse("not json") == nil)
        #expect(JSONValue.parse(String(repeating: "[", count: 65) + String(repeating: "]", count: 65)) == nil)
        #expect(JSONValue.parse(#""[[[[""#) == .string("[[[["))
    }

    @Test func describesTypesAndText() {
        #expect(JSONValue.number(2).typeName == "integer")
        #expect(JSONValue.number(2.5).typeName == "number")
        #expect(JSONValue.string("x").text == "x")
        #expect(JSONValue.object(["b": .null, "a": .bool(false)]).text == #"{"a":false,"b":null}"#)
    }
}

@Suite("Fingerprints")
struct FingerprintTests {
    @Test func changeWithEverythingThatShapesTheInput() throws {
        let base = TestCase(id: "a", prompt: "Hello", assertions: [Assertion(.maxLength(5))])
        var reworded = base
        reworded.prompt = "Hello!"
        var instructed = base
        instructed.settings.instructions = "Be brief."
        var sampled = base
        sampled.settings.sampling = .random
        var structured = base
        structured.schema = .boolean(description: nil)
        var checked = base
        checked.assertions = [Assertion(.maxLength(9))]
        checked.repeatCount = 4

        let prints = [base, reworded, instructed, sampled, structured].map(\.fingerprint)
        #expect(Set(prints).count == prints.count)
        // Assertions and repeats do not change what the model sees.
        #expect(checked.fingerprint == base.fingerprint)
        #expect(base.fingerprint.count == 64)
    }
}
