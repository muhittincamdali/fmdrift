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
/// leaving one busy thread per match.
enum PatternMatch {
    enum Outcome: Sendable, Equatable {
        case matched
        case notMatched
        case timedOut
    }

    /// Far above what a sound pattern needs on any answer the model can give (microseconds).
    static let timeLimit: Double = 2

    private static let slowPatterns = SlowPatterns()

    /// Why a check gave up, for the report.
    static func timedOutDetail(_ pattern: String, limit: Double = timeLimit) -> String {
        "gave up on /\(pattern)/: matching took over \(Format.duration(limit)), it backtracks too much; simplify it"
    }

    /// An invalid pattern does not match; suites and schemas are checked when they are read.
    static func run(_ pattern: String, in text: String, limit: Double = timeLimit) -> Outcome {
        if slowPatterns.contains(pattern) { return .timedOut }
        let box = OutcomeBox()
        let thread = Thread {
            let regex = try? Regex(pattern)
            let matched = regex.map { (try? $0.firstMatch(in: text)) != nil } ?? false
            box.finish(matched ? .matched : .notMatched)
        }
        // Compiling a deeply nested pattern recurses; give it the room the suite reader has.
        thread.stackSize = SuiteLoader.parserStackSize
        thread.start()
        guard let outcome = box.wait(seconds: limit) else {
            slowPatterns.insert(pattern)
            return .timedOut
        }
        return outcome
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
