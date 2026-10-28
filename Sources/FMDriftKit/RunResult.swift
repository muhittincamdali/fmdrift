import Foundation

/// Everything a run produced. `fmdrift record` writes it as a snapshot; `--json` prints it.
public struct RunResult: Sendable, Equatable, Codable {
    /// Version of this file format. Readers refuse a newer major format.
    public static let currentFormat = 1

    public var format: Int
    public var fmdriftVersion: String
    public var suite: String
    public var recordedAt: Date
    /// Wall-clock seconds for the whole run.
    public var duration: Double
    public var environment: RunEnvironment
    public var cases: [CaseResult]

    public init(
        suite: String,
        recordedAt: Date,
        duration: Double,
        environment: RunEnvironment,
        cases: [CaseResult],
        fmdriftVersion: String = FMDrift.version,
        format: Int = RunResult.currentFormat
    ) {
        self.format = format
        self.fmdriftVersion = fmdriftVersion
        self.suite = suite
        self.recordedAt = recordedAt
        self.duration = duration
        self.environment = environment
        self.cases = cases
    }

    /// Snapshots with a longer run are refused: a year is far beyond any real run.
    public static let maximumDuration: Double = 365 * 86_400

    enum CodingKeys: String, CodingKey {
        case format, fmdriftVersion, suite, recordedAt, duration, environment, cases
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decoded in the order of the stored properties, so a missing key is reported as before.
        let format = try container.decode(Int.self, forKey: .format)
        let fmdriftVersion = try container.decode(String.self, forKey: .fmdriftVersion)
        let suite = try container.decode(String.self, forKey: .suite)
        let recordedAt = try container.decode(Date.self, forKey: .recordedAt)
        let duration = try container.decode(Double.self, forKey: .duration)
        guard duration.isFinite, duration >= 0, duration <= Self.maximumDuration else {
            throw DecodingError.dataCorruptedError(
                forKey: .duration,
                in: container,
                debugDescription: "duration must be between 0 and \(Self.maximumDuration) seconds"
            )
        }
        self.init(
            suite: suite,
            recordedAt: recordedAt,
            duration: duration,
            environment: try container.decode(RunEnvironment.self, forKey: .environment),
            cases: try container.decode([CaseResult].self, forKey: .cases),
            fmdriftVersion: fmdriftVersion,
            format: format
        )
    }

    public var passed: Bool { cases.allSatisfy(\.passed) }
    public var passedCount: Int { cases.filter(\.passed).count }
    public var failedCount: Int { cases.count - passedCount }
    public var generationCount: Int { cases.reduce(0) { $0 + $1.samples.count } }
}

/// The responses to one case and how they fared.
public struct CaseResult: Sendable, Equatable, Codable {
    public var id: String
    public var prompt: String
    public var fingerprint: String
    public var settings: GenerationSettings
    /// The schema as JSON Schema, for structured cases.
    public var schema: JSONValue?
    public var minPassRate: Double
    public var samples: [SampleResult]
    /// Remarks such as "prompt changed since this snapshot was recorded".
    public var notes: [String]

    // Derived from the samples; stored so JSON readers do not need to recompute them, and
    // recomputed when a snapshot is read so an edited file cannot claim a different outcome.
    public private(set) var passCount: Int
    public private(set) var passRate: Double
    public private(set) var passed: Bool
    /// Share of samples identical to the most common output.
    public private(set) var agreement: Double

    public init(
        id: String,
        prompt: String,
        fingerprint: String,
        settings: GenerationSettings,
        schema: JSONValue?,
        minPassRate: Double,
        samples: [SampleResult],
        notes: [String] = []
    ) {
        self.id = id
        self.prompt = prompt
        self.fingerprint = fingerprint
        self.settings = settings
        self.schema = schema
        self.minPassRate = minPassRate
        self.samples = samples
        self.notes = notes
        passCount = 0
        passRate = 0
        passed = false
        agreement = 0
        recompute()
    }

    enum CodingKeys: String, CodingKey {
        case id, prompt, fingerprint, settings, schema, minPassRate, samples, notes
        case passCount, passRate, passed, agreement
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let prompt = try container.decode(String.self, forKey: .prompt)
        let fingerprint = try container.decode(String.self, forKey: .fingerprint)
        let settings = try container.decode(GenerationSettings.self, forKey: .settings)
        let schema = try container.decodeIfPresent(JSONValue.self, forKey: .schema)
        let minPassRate = try container.decode(Double.self, forKey: .minPassRate)
        guard minPassRate >= 0, minPassRate <= 1 else {
            throw DecodingError.dataCorruptedError(
                forKey: .minPassRate, in: container, debugDescription: "minPassRate must be between 0 and 1")
        }
        self.init(
            id: id,
            prompt: prompt,
            fingerprint: fingerprint,
            settings: settings,
            schema: schema,
            minPassRate: minPassRate,
            samples: try container.decode([SampleResult].self, forKey: .samples),
            notes: try container.decodeIfPresent([String].self, forKey: .notes) ?? []
        )
    }

    private mutating func recompute() {
        passCount = samples.filter(\.passed).count
        passRate = samples.isEmpty ? 0 : Double(passCount) / Double(samples.count)
        // A tiny tolerance so 2 of 3 passes a 0.66 rate written as 66%.
        passed = !samples.isEmpty && passRate + 1e-9 >= minPassRate
        if let mode = outputCounts.first {
            agreement = Double(mode.count) / Double(samples.count)
        } else {
            agreement = 0
        }
    }

    /// Distinct outputs with how often each occurred, most frequent first (ties keep the order
    /// of first appearance). Errors count as `[kind]`.
    public var outputCounts: [(output: String, count: Int)] {
        var order: [String] = []
        var counts: [String: Int] = [:]
        for sample in samples {
            let key = sample.outputKey(structured: schema != nil)
            if counts[key] == nil { order.append(key) }
            counts[key, default: 0] += 1
        }
        let entries: [(output: String, count: Int)] = order.map { ($0, counts[$0] ?? 0) }
        // Stable: equal counts keep the order of first appearance.
        let ranked = entries.indices.sorted { left, right in
            let leftCount = entries[left].count
            let rightCount = entries[right].count
            return leftCount != rightCount ? leftCount > rightCount : left < right
        }
        return ranked.map { entries[$0] }
    }

    /// The most common output, which reports and diffs show for the case.
    public var representativeOutput: String {
        outputCounts.first?.output ?? ""
    }

    public var medianLatency: Double? {
        Statistics.median(samples.map(\.generation.latency))
    }

    public var medianOutputTokens: Double? {
        Statistics.median(samples.compactMap(\.generation.outputTokens).map(Double.init))
    }
}

/// One response and the outcome of each check on it.
public struct SampleResult: Sendable, Equatable, Codable {
    public var generation: Generation
    public var checks: [CheckResult]

    public init(generation: Generation, checks: [CheckResult]) {
        self.generation = generation
        self.checks = checks
    }

    /// No check failed. Skipped checks do not fail a sample.
    public var passed: Bool { !checks.contains { $0.status == .failed } }

    /// The text that counts toward agreement: the output, or `[kind]` for an error. A
    /// structured answer counts by value: guided generation on macOS 27.0.1 returned the same
    /// properties in different orders across greedy runs, so its JSON is compared with sorted keys.
    public func outputKey(structured: Bool) -> String {
        if let failure = generation.failure { return "[\(failure.kind.rawValue)]" }
        let text = generation.text ?? ""
        if structured, let value = JSONValue.parse(text) { return value.compactJSON }
        return text
    }
}

enum Statistics {
    static func median(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count % 2 == 1 { return sorted[middle] }
        return (sorted[middle - 1] + sorted[middle]) / 2
    }
}
