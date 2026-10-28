import Foundation

/// What changed between two runs of the same suite, usually recorded on two OS builds.
public struct SnapshotDiff: Sendable, Equatable, Codable {
    public struct Side: Sendable, Equatable, Codable {
        public var suite: String
        public var environment: RunEnvironment
        public var recordedAt: Date
        public var fmdriftVersion: String
    }

    public enum Status: String, Sendable, Codable, CaseIterable {
        /// Passed in the baseline, fails now.
        case regressed
        /// Failed in the baseline, passes now.
        case fixed
        /// Failed in both.
        case stillFailing
        /// Passes in both, but the most common output or the pass rate is different.
        case changed
        case unchanged
        /// Only in the current run.
        case added
        /// Only in the baseline.
        case removed
    }

    /// The figures of one side of a case.
    public struct CaseSide: Sendable, Equatable, Codable {
        public var passed: Bool
        public var passRate: Double
        public var agreement: Double
        public var samples: Int
        public var medianLatency: Double?
        public var medianOutputTokens: Double?
        public var output: String

        init(_ result: CaseResult) {
            passed = result.passed
            passRate = result.passRate
            agreement = result.agreement
            samples = result.samples.count
            medianLatency = result.medianLatency
            medianOutputTokens = result.medianOutputTokens
            output = result.representativeOutput
        }
    }

    public struct CaseChange: Sendable, Equatable, Codable {
        public var id: String
        public var status: Status
        /// The prompt, instructions, options or schema differ between the two runs, so a change
        /// may come from the suite rather than the model.
        public var inputChanged: Bool
        public var baseline: CaseSide?
        public var current: CaseSide?
        /// Checks that fail now and passed in every baseline response.
        public var newlyFailingChecks: [String]
        /// Median latency grew by more than the allowed share.
        public var slower: Bool
    }

    public var baseline: Side
    public var current: Side
    public var cases: [CaseChange]

    public func count(_ status: Status) -> Int {
        cases.filter { $0.status == status }.count
    }

    public var slowerCount: Int { cases.filter(\.slower).count }

    /// Compares two runs case by case.
    /// - Parameter latencyIncrease: Share (0.5 = 50%) by which the median latency may grow
    ///   before a case counts as slower; nil never marks a case slower.
    public init(baseline: RunResult, current: RunResult, latencyIncrease: Double? = nil) {
        self.baseline = Side(
            suite: baseline.suite,
            environment: baseline.environment,
            recordedAt: baseline.recordedAt,
            fmdriftVersion: baseline.fmdriftVersion
        )
        self.current = Side(
            suite: current.suite,
            environment: current.environment,
            recordedAt: current.recordedAt,
            fmdriftVersion: current.fmdriftVersion
        )
        let before = Dictionary(baseline.cases.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let after = Dictionary(current.cases.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        var changes: [CaseChange] = []
        for result in current.cases {
            guard let old = before[result.id] else {
                changes.append(
                    CaseChange(
                        id: result.id,
                        status: .added,
                        inputChanged: false,
                        baseline: nil,
                        current: CaseSide(result),
                        newlyFailingChecks: [],
                        slower: false
                    )
                )
                continue
            }
            changes.append(Self.compare(old, result, latencyIncrease: latencyIncrease))
        }
        for result in baseline.cases where after[result.id] == nil {
            changes.append(
                CaseChange(
                    id: result.id,
                    status: .removed,
                    inputChanged: false,
                    baseline: CaseSide(result),
                    current: nil,
                    newlyFailingChecks: [],
                    slower: false
                )
            )
        }
        cases = changes
    }

    static func compare(_ old: CaseResult, _ new: CaseResult, latencyIncrease: Double?) -> CaseChange {
        let before = CaseSide(old)
        let after = CaseSide(new)
        let status: Status
        switch (old.passed, new.passed) {
        case (true, false): status = .regressed
        case (false, true): status = .fixed
        case (false, false): status = .stillFailing
        case (true, true):
            let outputChanged = before.output != after.output
            let rateChanged = abs(before.passRate - after.passRate) > 1e-9
            status = outputChanged || rateChanged ? .changed : .unchanged
        }
        let failedBefore = Set(old.samples.flatMap { $0.checks.filter { $0.status == .failed }.map(\.label) })
        var newlyFailing: [String] = []
        for sample in new.samples {
            for check in sample.checks where check.status == .failed {
                if !failedBefore.contains(check.label), !newlyFailing.contains(check.label) {
                    newlyFailing.append(check.label)
                }
            }
        }
        var slower = false
        if let latencyIncrease, let oldLatency = before.medianLatency, let newLatency = after.medianLatency,
            oldLatency > 0
        {
            slower = (newLatency - oldLatency) / oldLatency > latencyIncrease
        }
        return CaseChange(
            id: new.id,
            status: status,
            inputChanged: old.fingerprint != new.fingerprint,
            baseline: before,
            current: after,
            newlyFailingChecks: newlyFailing,
            slower: slower
        )
    }

    /// Which differences make `fmdrift diff` (and `run --baseline`) exit with 1.
    public enum FailurePolicy: String, Sendable, CaseIterable {
        /// A case that passed now fails, or a case is slower than allowed. The default.
        case regressed
        /// Also any changed output or pass rate, added or removed case.
        case changed
        /// Never; report only.
        case never
    }

    public func fails(under policy: FailurePolicy) -> Bool {
        switch policy {
        case .never:
            return false
        case .regressed:
            return count(.regressed) > 0 || slowerCount > 0
        case .changed:
            return cases.contains { $0.status != .unchanged && $0.status != .stillFailing && $0.status != .fixed }
                || slowerCount > 0
        }
    }
}
