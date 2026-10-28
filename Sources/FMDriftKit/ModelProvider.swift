import Foundation

/// What the runner asks a model for: one response to one case.
public struct GenerationRequest: Sendable, Equatable {
    public var caseID: String
    public var prompt: String
    public var settings: GenerationSettings
    public var schema: JSONSchema?
    /// Zero-based index of this run among the case's repeats.
    public var sampleIndex: Int

    public init(caseID: String, prompt: String, settings: GenerationSettings, schema: JSONSchema?, sampleIndex: Int) {
        self.caseID = caseID
        self.prompt = prompt
        self.settings = settings
        self.schema = schema
        self.sampleIndex = sampleIndex
    }
}

/// Whether a provider can answer at all.
public enum ModelAvailability: Sendable, Equatable {
    case available
    /// `reason` is a short code such as `appleIntelligenceNotEnabled`; `explanation` says what to do.
    case unavailable(reason: String, explanation: String)

    public var code: String {
        switch self {
        case .available: "available"
        case .unavailable(let reason, _): reason
        }
    }
}

/// Something that answers prompts: the on-device model, or recorded responses.
public protocol ModelProvider: Sendable {
    func availability() async -> ModelAvailability
    func environment() async -> RunEnvironment
    /// One response in a new session. Errors are returned as a ``Generation/failure``, never thrown.
    func generate(_ request: GenerationRequest) async -> Generation
}

/// Answers with the responses stored in a snapshot, so checks can be re-run without a model:
/// on a CI runner without Apple Intelligence, or after editing the checks of a suite.
public struct ReplayProvider: ModelProvider {
    public let snapshot: RunResult
    private let samples: [String: [Generation]]

    public init(snapshot: RunResult) {
        self.snapshot = snapshot
        var samples: [String: [Generation]] = [:]
        for result in snapshot.cases {
            samples[result.id] = result.samples.map(\.generation)
        }
        self.samples = samples
    }

    public func availability() async -> ModelAvailability { .available }

    public func environment() async -> RunEnvironment {
        var environment = snapshot.environment
        environment.provider = "replay"
        return environment
    }

    /// How many recorded responses there are for a case; the runner replays exactly these.
    public func recordedCount(for caseID: String) -> Int {
        samples[caseID]?.count ?? 0
    }

    public func generate(_ request: GenerationRequest) async -> Generation {
        guard let recorded = samples[request.caseID], recorded.indices.contains(request.sampleIndex) else {
            return .failed(
                .other,
                "the snapshot has no response \(request.sampleIndex + 1) for case `\(request.caseID)`",
                latency: 0
            )
        }
        return recorded[request.sampleIndex]
    }
}
