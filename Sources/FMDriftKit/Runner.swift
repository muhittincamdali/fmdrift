import Foundation

/// Runs a suite against a provider, one generation at a time.
///
/// Generations run in sequence: the on-device model serves one request at a time, and
/// sequential runs keep latency numbers comparable between snapshots.
public struct Runner: Sendable {
    public var provider: any ModelProvider

    public init(provider: any ModelProvider) {
        self.provider = provider
    }

    /// Progress after each generation.
    public struct Progress: Sendable, Equatable {
        public var caseID: String
        public var sample: Int
        public var samples: Int
        public var completed: Int
        public var total: Int
        public var passed: Bool
    }

    /// Runs every selected case and checks each answer.
    /// - Parameters:
    ///   - suite: The suite to run.
    ///   - selection: Case ids to run; nil runs all.
    ///   - sampleCount: Runs per case; nil uses each case's `repeat`.
    ///   - progress: Called after each generation.
    public func run(
        _ suite: Suite,
        cases selection: Set<String>? = nil,
        sampleCount: (@Sendable (TestCase) -> Int)? = nil,
        progress: (@Sendable (Progress) -> Void)? = nil
    ) async -> RunResult {
        let clock = ContinuousClock()
        let start = clock.now
        let recordedAt = Date()
        let environment = await provider.environment()
        let selected = suite.cases.filter { selection?.contains($0.id) ?? true }
        let counts = selected.map { max(0, sampleCount?($0) ?? $0.repeatCount) }
        let total = counts.reduce(0, +)
        var completed = 0
        var results: [CaseResult] = []

        for (testCase, count) in zip(selected, counts) {
            var samples: [SampleResult] = []
            for index in 0..<count {
                let request = GenerationRequest(
                    caseID: testCase.id,
                    prompt: testCase.prompt,
                    settings: testCase.settings,
                    schema: testCase.schema,
                    sampleIndex: index
                )
                var generation = await provider.generate(request)
                generation.latency = (generation.latency * 1000).rounded() / 1000
                let sample = SampleResult(
                    generation: generation,
                    checks: Evaluator.evaluate(generation, for: testCase)
                )
                samples.append(sample)
                completed += 1
                progress?(
                    Progress(
                        caseID: testCase.id,
                        sample: index + 1,
                        samples: count,
                        completed: completed,
                        total: total,
                        passed: sample.passed
                    )
                )
            }
            results.append(
                CaseResult(
                    id: testCase.id,
                    prompt: testCase.prompt,
                    fingerprint: testCase.fingerprint,
                    settings: testCase.settings,
                    schema: testCase.schema?.jsonValue,
                    minPassRate: testCase.minPassRate,
                    samples: samples,
                    notes: count == 0 ? ["no responses to check"] : []
                )
            )
        }

        let elapsed = clock.now - start
        let seconds = Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18
        return RunResult(
            suite: suite.name,
            recordedAt: recordedAt,
            duration: (seconds * 1000).rounded() / 1000,
            environment: environment,
            cases: results
        )
    }
}
