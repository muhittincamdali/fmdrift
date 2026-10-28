import Foundation

/// Matches a regular expression from a suite with a time limit.
///
/// Swift's `Regex` has no step limit and does not stop when its task is cancelled. A pattern
/// that backtracks catastrophically, such as `^(a+)+$`, took more than a minute on a
/// 29-character answer and kept `run --replay` busy for as long. The match runs on a thread of
/// its own; when it takes longer than the limit, the check gives up and fails, and the thread is
/// left to finish in the background.
///
/// A pattern that gave up once gives up at once on every later text in the process. Otherwise a
/// suite could repeat it over hundreds of cases and samples, waiting the limit each time and
/// leaving one busy thread per match. Distinct slow patterns are bounded by a shared
/// ``PatternBudget``.
enum PatternMatch {
    enum Outcome: Sendable, Equatable {
        case matched
        case notMatched
        case timedOut
        /// Not tried: the run had already spent its budget for regular expressions.
        case budgetSpent
    }

    /// Far above what a sound pattern needs on any answer the model can give (microseconds).
    static let timeLimit: Double = 2

    private static let slowPatterns = SlowPatterns()

    /// Why a check failed without a match, for the report; nil when the pattern was tried.
    static func detail(_ outcome: Outcome, pattern: String, limit: Double = timeLimit) -> String? {
        switch outcome {
        case .matched, .notMatched:
            return nil
        case .timedOut:
            return "gave up on /\(pattern)/: matching took over \(Format.duration(limit)), it backtracks too much; "
                + "simplify it"
        case .budgetSpent:
            return "did not try /\(pattern)/: fmdrift already gave up on \(PatternBudget.maximumGiveUps) "
                + "regular expressions or spent \(Format.duration(PatternBudget.maximumSeconds)) matching them; "
                + "simplify the patterns that backtrack"
        }
    }

    /// An invalid pattern does not match; suites and schemas are checked when they are read.
    static func run(
        _ pattern: String,
        in text: String,
        budget: PatternBudget = PatternBudget(),
        limit: Double = timeLimit
    ) -> Outcome {
        if slowPatterns.contains(pattern) { return .timedOut }
        guard let allowance = budget.allowance(limit: limit) else { return .budgetSpent }
        let box = OutcomeBox()
        let thread = Thread {
            let regex = try? Regex(pattern)
            let matched = regex.map { (try? $0.firstMatch(in: text)) != nil } ?? false
            box.finish(matched ? .matched : .notMatched)
        }
        // Compiling a deeply nested pattern recurses; give it the room the suite reader has.
        thread.stackSize = SuiteLoader.parserStackSize
        let started = DispatchTime.now()
        thread.start()
        let outcome = box.wait(seconds: allowance)
        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - started.uptimeNanoseconds) / 1e9
        budget.charge(seconds: elapsed, gaveUp: outcome == nil)
        if let outcome { return outcome }
        // A wait the budget cut short says nothing about the pattern itself.
        guard allowance >= limit else { return .budgetSpent }
        slowPatterns.insert(pattern)
        return .timedOut
    }
}

/// What regular expressions from suites and schemas may cost, shared by every run it is given to.
///
/// The time limit bounds one match, not a run: each distinct pattern that backtracks costs
/// another full limit, and its thread keeps running after the check gives up because a `Regex`
/// match cannot be stopped. Twenty such patterns in a 1 KB suite kept `run --replay` busy for
/// 40 s and burned 384 s of CPU time on 20 threads. A budget for each suite was not enough
/// either: ten suites with two such patterns each, run from one folder, cost the same 40 s and
/// 20 threads. Once the budget has given up on ``maximumGiveUps`` matches, or spent
/// ``maximumSeconds`` matching, later patterns are not tried and their checks fail. A sound
/// pattern takes microseconds, so only patterns that backtrack reach either bound.
///
/// A ``Runner`` makes a budget of its own unless it is given one. To bound several suites
/// together, as `fmdrift run` does for all the suites of one command, give each runner the same
/// budget.
public final class PatternBudget: @unchecked Sendable {
    /// Bounds the threads left running and the time spent waiting for them.
    public static let maximumGiveUps = 2
    /// Bounds patterns that are slow but finish within the time limit.
    public static let maximumSeconds: Double = 30

    private let giveUpLimit: Int
    private let secondsLimit: Double
    private let lock = NSLock()
    private var giveUps = 0
    private var seconds: Double = 0

    /// A budget of ``maximumGiveUps`` abandoned matches and ``maximumSeconds`` of matching.
    public convenience init() {
        self.init(maximumGiveUps: Self.maximumGiveUps, maximumSeconds: Self.maximumSeconds)
    }

    init(maximumGiveUps: Int, maximumSeconds: Double) {
        giveUpLimit = maximumGiveUps
        secondsLimit = maximumSeconds
    }

    /// How long the next match may take; nil when the budget is spent.
    func allowance(limit: Double) -> Double? {
        lock.withLock {
            guard giveUps < giveUpLimit, seconds < secondsLimit else { return nil }
            return min(limit, secondsLimit - seconds)
        }
    }

    func charge(seconds elapsed: Double, gaveUp: Bool) {
        lock.withLock {
            seconds += elapsed
            if gaveUp { giveUps += 1 }
        }
    }
}

private final class SlowPatterns: @unchecked Sendable {
    private let lock = NSLock()
    private var patterns: Set<String> = []

    func contains(_ pattern: String) -> Bool { lock.withLock { patterns.contains(pattern) } }
    func insert(_ pattern: String) { _ = lock.withLock { patterns.insert(pattern) } }
}

private final class OutcomeBox: @unchecked Sendable {
    private let lock = NSLock()
    private let finished = DispatchSemaphore(value: 0)
    private var outcome: PatternMatch.Outcome?

    func finish(_ value: PatternMatch.Outcome) {
        lock.withLock { outcome = value }
        finished.signal()
    }

    func wait(seconds: Double) -> PatternMatch.Outcome? {
        guard finished.wait(timeout: .now() + seconds) == .success else { return nil }
        return lock.withLock { outcome }
    }
}
