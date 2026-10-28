import Foundation
import Yams

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

    func visit(_ node: Node) throws {
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
}
