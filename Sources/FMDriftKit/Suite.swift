import Foundation

/// A test suite: prompts for the on-device model and what their responses must satisfy.
///
/// Suites are YAML (or JSON) files read by ``SuiteLoader``. Settings in `defaults` apply to
/// every case unless the case sets them itself.
public struct Suite: Sendable, Equatable {
    public var name: String
    public var cases: [TestCase]

    public init(name: String, cases: [TestCase]) {
        self.name = name
        self.cases = cases
    }
}

/// One prompt and the checks its responses must pass.
public struct TestCase: Sendable, Equatable {
    public var id: String
    public var prompt: String
    public var settings: GenerationSettings
    /// When set, the response is generated with guided generation against this schema and the
    /// case checks that the result conforms to it.
    public var schema: JSONSchema?
    public var assertions: [Assertion]
    /// How many times the prompt runs. Each run starts a new session.
    public var repeatCount: Int
    /// Share of runs that must pass every assertion, from 0 to 1.
    public var minPassRate: Double

    public init(
        id: String,
        prompt: String,
        settings: GenerationSettings = GenerationSettings(),
        schema: JSONSchema? = nil,
        assertions: [Assertion] = [],
        repeatCount: Int = 1,
        minPassRate: Double = 1
    ) {
        self.id = id
        self.prompt = prompt
        self.settings = settings
        self.schema = schema
        self.assertions = assertions
        self.repeatCount = repeatCount
        self.minPassRate = minPassRate
    }

    /// A stable hash of everything that shapes the model's input: prompt, instructions,
    /// generation options and schema. ``SnapshotDiff`` uses it to tell a changed prompt apart
    /// from a changed model.
    public var fingerprint: String {
        var parts = [
            "prompt:\(prompt)",
            "instructions:\(settings.instructions ?? "")",
            "sampling:\(settings.sampling.description)",
            "temperature:\(settings.temperature.map { String($0) } ?? "")",
            "maxResponseTokens:\(settings.maximumResponseTokens.map { String($0) } ?? "")",
            "guardrails:\(settings.guardrails.rawValue)",
            "useCase:\(settings.useCase.rawValue)",
        ]
        if let schema {
            parts.append("schema:\(schema.canonicalJSON)")
        }
        return SHA256Digest.hex(of: parts.joined(separator: "\n"))
    }
}

/// Options passed to the model for one case.
public struct GenerationSettings: Sendable, Equatable, Codable {
    public var instructions: String?
    public var sampling: Sampling
    public var temperature: Double?
    public var maximumResponseTokens: Int?
    public var guardrails: Guardrails
    public var useCase: UseCase

    public init(
        instructions: String? = nil,
        sampling: Sampling = .greedy,
        temperature: Double? = nil,
        maximumResponseTokens: Int? = nil,
        guardrails: Guardrails = .default,
        useCase: UseCase = .general
    ) {
        self.instructions = instructions
        self.sampling = sampling
        self.temperature = temperature
        self.maximumResponseTokens = maximumResponseTokens
        self.guardrails = guardrails
        self.useCase = useCase
    }
}

/// How the model picks tokens. Greedy is the default because a regression test should give the
/// same answer on the same model; random sampling with repeats measures how stable a prompt is.
public enum Sampling: Sendable, Equatable, Codable, CustomStringConvertible {
    case greedy
    case randomTop(Int, seed: UInt64?)
    case randomProbability(Double, seed: UInt64?)
    /// Random sampling with the framework's default parameters.
    case random(seed: UInt64?)

    public var description: String {
        switch self {
        case .greedy: "greedy"
        case .random(let seed): "random" + Self.seedSuffix(seed)
        case .randomTop(let top, let seed): "random top \(top)" + Self.seedSuffix(seed)
        case .randomProbability(let threshold, let seed):
            "random probability \(threshold)" + Self.seedSuffix(seed)
        }
    }

    private static func seedSuffix(_ seed: UInt64?) -> String {
        seed.map { " seed \($0)" } ?? ""
    }

    public var isGreedy: Bool {
        if case .greedy = self { return true }
        return false
    }
}

/// The guardrail setting of `SystemLanguageModel`.
public enum Guardrails: String, Sendable, Equatable, Codable, CaseIterable {
    case `default`
    /// `SystemLanguageModel.Guardrails.permissiveContentTransformations`, for prompts that
    /// transform text the person supplied.
    case permissiveContentTransformations
}

/// The use case of `SystemLanguageModel`.
public enum UseCase: String, Sendable, Equatable, Codable, CaseIterable {
    case general
    case contentTagging
}
