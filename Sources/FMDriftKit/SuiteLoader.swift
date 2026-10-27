import Foundation
import Yams

/// Reads suite files (YAML, or JSON, which is valid YAML).
///
/// Every key is checked: an unknown key is an error with a "did you mean" hint, because a typo
/// in an assertion would otherwise make a test pass without checking anything.
public enum SuiteLoader {
    /// Larger files are refused before parsing.
    public static let maximumFileSize = 1_048_576
    public static let maximumCases = 500
    public static let maximumRepeat = 100
    public static let maximumPromptLength = 100_000
    /// Upper bound on YAML nodes visited, so aliases that expand exponentially cannot stall the
    /// reader.
    static let maximumNodes = 200_000

    static let topKeys: Set<String> = ["name", "defaults", "cases"]
    static let settingKeys: Set<String> = [
        "instructions", "sampling", "temperature", "maxResponseTokens", "guardrails", "useCase", "repeat",
        "minPassRate",
    ]
    static let caseKeys: Set<String> = settingKeys.union(["id", "prompt", "schema", "expect"])

    /// Reads a suite file. The suite name defaults to the file name without its extension.
    public static func load(contentsOf url: URL) throws(SuiteError) -> Suite {
        let file = url.lastPathComponent
        let data: Data
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? Int, size > maximumFileSize {
                throw SuiteError(
                    file: file, message: "is \(size) bytes; suites are limited to \(maximumFileSize) bytes")
            }
            data = try Data(contentsOf: url)
        } catch let error as SuiteError {
            throw error
        } catch {
            throw SuiteError(file: file, message: "cannot be read (\(error.localizedDescription))")
        }
        guard data.count <= maximumFileSize else {
            throw SuiteError(file: file, message: "is larger than \(maximumFileSize) bytes")
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw SuiteError(file: file, message: "is not UTF-8 text")
        }
        let defaultName = url.deletingPathExtension().lastPathComponent
        return try parse(text, file: file, defaultName: defaultName)
    }

    /// Reads suite text. `file` is used in error messages only.
    public static func parse(_ text: String, file: String = "suite", defaultName: String = "suite") throws(SuiteError)
        -> Suite
    {
        guard text.utf8.count <= maximumFileSize else {
            throw SuiteError(file: file, message: "is larger than \(maximumFileSize) bytes")
        }
        let root: Node?
        do {
            root = try Yams.compose(yaml: text)
        } catch let error as YamlError {
            throw SuiteError(file: file, line: yamlLine(error), message: "is not valid YAML: \(yamlProblem(error))")
        } catch {
            throw SuiteError(file: file, message: "is not valid YAML")
        }
        guard let root else {
            throw SuiteError(file: file, message: "is empty; a suite needs `cases`")
        }
        let reader = NodeReader(file: file)
        do {
            return try reader.suite(root, defaultName: defaultName)
        } catch let error as SuiteError {
            throw error
        } catch {
            throw SuiteError(file: file, message: "\(error)")
        }
    }

    private static func yamlLine(_ error: YamlError) -> Int? {
        switch error {
        case .scanner(_, _, let mark, _), .parser(_, _, let mark, _), .composer(_, _, let mark, _):
            return mark.line
        default:
            return nil
        }
    }

    private static func yamlProblem(_ error: YamlError) -> String {
        switch error {
        case .scanner(_, let problem, _, _), .parser(_, let problem, _, _), .composer(_, let problem, _, _):
            return problem
        case .duplicatedKeysInMapping(let duplicates, _):
            return "duplicate keys \(duplicates.joined(separator: ", "))"
        default:
            return "\(error)"
        }
    }
}

/// Walks the YAML tree and builds the suite, keeping the file name for messages.
final class NodeReader {
    let file: String
    private var visited = 0

    init(file: String) {
        self.file = file
    }

    func error(_ node: Node?, _ message: String) -> SuiteError {
        SuiteError(file: file, line: node?.mark?.line, message: message)
    }

    private func visit(_ node: Node) throws {
        visited += 1
        if visited > SuiteLoader.maximumNodes {
            throw error(node, "has more than \(SuiteLoader.maximumNodes) YAML nodes")
        }
    }

    // MARK: Suite

    func suite(_ root: Node, defaultName: String) throws -> Suite {
        let top = try mapping(root, "the suite", allowed: SuiteLoader.topKeys)
        let name: String
        if let node = top["name"] {
            name = try identifier(node, "name")
        } else {
            name = Self.sanitizedName(defaultName)
        }
        var defaults = CaseDefaults()
        if let node = top["defaults"] {
            let entries = try mapping(node, "defaults", allowed: SuiteLoader.settingKeys)
            defaults = try caseDefaults(entries, base: defaults, context: "defaults")
        }
        guard let casesNode = top["cases"] else {
            throw error(root, "needs a `cases` list")
        }
        guard case .sequence(let sequence) = casesNode, !sequence.isEmpty else {
            throw error(casesNode, "`cases` must be a non-empty list")
        }
        guard sequence.count <= SuiteLoader.maximumCases else {
            throw error(casesNode, "has \(sequence.count) cases; a suite may have at most \(SuiteLoader.maximumCases)")
        }
        var cases: [TestCase] = []
        var seen: [String: Int] = [:]
        for (index, node) in sequence.enumerated() {
            let testCase = try self.testCase(node, index: index, defaults: defaults)
            if let first = seen[testCase.id] {
                throw error(node, "case id `\(testCase.id)` is already used by case \(first + 1)")
            }
            seen[testCase.id] = index
            cases.append(testCase)
        }
        return Suite(name: name, cases: cases)
    }

    /// File names may hold anything; suite names end up in snapshot paths, so keep a safe subset.
    static func sanitizedName(_ text: String) -> String {
        let allowed = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
        var name = String(text.map { allowed.contains($0) ? $0 : "-" }.prefix(64))
        while name.hasPrefix(".") { name.removeFirst() }
        return name.isEmpty ? "suite" : name
    }

    // MARK: Cases

    struct CaseDefaults {
        var settings = GenerationSettings()
        var repeatCount = 1
        var minPassRate = 1.0
    }

    func testCase(_ node: Node, index: Int, defaults: CaseDefaults) throws -> TestCase {
        let context = "case \(index + 1)"
        let entries = try mapping(node, context, allowed: SuiteLoader.caseKeys)
        guard let idNode = entries["id"] else {
            throw error(node, "\(context) needs an `id`")
        }
        let id = try identifier(idNode, "id")
        let caseContext = "case `\(id)`"
        guard let promptNode = entries["prompt"] else {
            throw error(node, "\(caseContext) needs a `prompt`")
        }
        let prompt = try string(promptNode, "prompt")
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw error(promptNode, "\(caseContext): `prompt` is empty")
        }
        guard prompt.count <= SuiteLoader.maximumPromptLength else {
            throw error(
                promptNode, "\(caseContext): `prompt` is longer than \(SuiteLoader.maximumPromptLength) characters")
        }
        let resolved = try caseDefaults(entries, base: defaults, context: caseContext)
        var schema: JSONSchema?
        if let schemaNode = entries["schema"] {
            let value = try json(schemaNode)
            do {
                schema = try JSONSchema.parse(value, at: "\(caseContext) schema")
            } catch {
                throw self.error(schemaNode, error.description)
            }
        }
        var assertions: [Assertion] = []
        if let expectNode = entries["expect"] {
            guard case .sequence(let items) = expectNode else {
                throw error(expectNode, "\(caseContext): `expect` must be a list of checks")
            }
            for item in items {
                assertions.append(try assertion(item, context: caseContext, hasSchema: schema != nil))
            }
        }
        if assertions.isEmpty, schema == nil {
            throw error(node, "\(caseContext) has nothing to check; add `expect` or a `schema`")
        }
        return TestCase(
            id: id,
            prompt: prompt,
            settings: resolved.settings,
            schema: schema,
            assertions: assertions,
            repeatCount: resolved.repeatCount,
            minPassRate: resolved.minPassRate
        )
    }

    func caseDefaults(_ entries: [String: Node], base: CaseDefaults, context: String) throws -> CaseDefaults {
        var result = base
        if let node = entries["instructions"] {
            let text = try string(node, "instructions")
            result.settings.instructions = text.isEmpty ? nil : text
        }
        if let node = entries["sampling"] {
            result.settings.sampling = try sampling(node)
        }
        if let node = entries["temperature"] {
            let value = try number(node, "temperature")
            guard value >= 0, value <= 2 else {
                throw error(node, "`temperature` must be between 0 and 2")
            }
            result.settings.temperature = value
        }
        if let node = entries["maxResponseTokens"] {
            result.settings.maximumResponseTokens = try integer(node, "maxResponseTokens", in: 1...100_000)
        }
        if let node = entries["guardrails"] {
            switch try string(node, "guardrails") {
            case "default": result.settings.guardrails = .default
            case "permissive", "permissiveContentTransformations":
                result.settings.guardrails = .permissiveContentTransformations
            case let other:
                throw error(node, "`guardrails` is `\(other)`; use `default` or `permissiveContentTransformations`")
            }
        }
        if let node = entries["useCase"] {
            let text = try string(node, "useCase")
            guard let useCase = UseCase(rawValue: text) else {
                throw error(node, "`useCase` is `\(text)`; use `general` or `contentTagging`")
            }
            result.settings.useCase = useCase
        }
        if let node = entries["repeat"] {
            result.repeatCount = try integer(node, "repeat", in: 1...SuiteLoader.maximumRepeat)
        }
        if let node = entries["minPassRate"] {
            result.minPassRate = try share(node, "minPassRate")
        }
        return result
    }

    func sampling(_ node: Node) throws -> Sampling {
        if case .scalar(let scalar) = node {
            switch scalar.string {
            case "greedy": return .greedy
            case "random": return .random
            default: throw error(node, "`sampling` is `\(scalar.string)`; use `greedy`, `random` or a mapping")
            }
        }
        let entries = try mapping(node, "sampling", allowed: ["mode", "top", "probabilityThreshold", "seed"])
        guard let modeNode = entries["mode"] else {
            throw error(node, "`sampling` needs `mode: random` (or write `sampling: greedy`)")
        }
        let mode = try string(modeNode, "mode")
        let seed = try entries["seed"].map { node in UInt64(try integer(node, "seed", in: 0...Int.max)) }
        if mode == "greedy" {
            guard entries.count == 1 else {
                throw error(node, "greedy sampling takes no `top`, `probabilityThreshold` or `seed`")
            }
            return .greedy
        }
        guard mode == "random" else {
            throw error(modeNode, "`mode` is `\(mode)`; use `greedy` or `random`")
        }
        switch (entries["top"], entries["probabilityThreshold"]) {
        case (let top?, nil):
            return .randomTop(try integer(top, "top", in: 1...1000), seed: seed)
        case (nil, let threshold?):
            let value = try number(threshold, "probabilityThreshold")
            guard value > 0, value <= 1 else {
                throw error(threshold, "`probabilityThreshold` must be greater than 0 and at most 1")
            }
            return .randomProbability(value, seed: seed)
        case (nil, nil):
            guard seed == nil else {
                throw error(
                    node,
                    "a `seed` needs `top` or `probabilityThreshold`; the framework takes a seed only with one of them")
            }
            return .random
        case (_?, _?):
            throw error(node, "use either `top` or `probabilityThreshold`, not both")
        }
    }

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

    func strings(_ node: Node, _ key: String) throws -> [String] {
        try visit(node)
        if case .sequence(let items) = node {
            guard !items.isEmpty else { throw error(node, "`\(key)` must not be an empty list") }
            return try items.map { try string($0, key) }
        }
        return [try string(node, key)]
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

    /// `2`, `2.5s`, `800ms`: seconds unless a unit is given.
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
        return value * scale
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
