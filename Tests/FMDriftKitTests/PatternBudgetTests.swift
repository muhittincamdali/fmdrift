import Foundation
import Testing

@testable import FMDriftKit

/// Slow patterns are remembered for the whole process, so each test uses patterns of its own.
@Suite("Time a run spends on regular expressions")
struct PatternBudgetTests {
    /// Backtracks for far longer than any limit below on `slowText`.
    private func slowPattern(_ tag: String) -> String { "^(e+)+$|\(tag)" }
    private let slowText = String(repeating: "e", count: 24) + "!"

    @Test func stopsTryingPatternsAfterTwoGiveUps() {
        let budget = PatternBudget()
        let started = Date()
        let outcomes = (1...4).map {
            PatternMatch.run(slowPattern("give-up-\($0)"), in: slowText, budget: budget, limit: 0.05)
        }
        #expect(outcomes == [.timedOut, .timedOut, .budgetSpent, .budgetSpent])
        // A sound pattern is not tried either once the budget is spent.
        #expect(PatternMatch.run(#"^\d+$"#, in: "2026", budget: budget) == .budgetSpent)
        #expect(Date().timeIntervalSince(started) < 1)
        // Another budget is not spent.
        #expect(PatternMatch.run(#"^\d+$"#, in: "2026", budget: PatternBudget()) == .matched)
    }

    @Test func stopsTryingPatternsAfterItsTimeIsSpent() {
        let budget = PatternBudget(maximumGiveUps: PatternBudget.maximumGiveUps, maximumSeconds: 0.05)
        let started = Date()
        // The budget cuts the wait short; that says nothing about the pattern itself.
        #expect(PatternMatch.run(slowPattern("seconds"), in: slowText, budget: budget) == .budgetSpent)
        #expect(PatternMatch.run(#"^\d+$"#, in: "2026", budget: budget) == .budgetSpent)
        #expect(Date().timeIntervalSince(started) < 1)
    }

    /// Twenty distinct slow patterns used to cost 2 s each, all in one run.
    @Test func boundsARunWithManySlowPatterns() async throws {
        let tags = (1...6).map { "run-\($0)" }
        let checks = tags.map { "      - matches: \"\(slowPattern($0))\"" }.joined(separator: "\n")
        let suite = try SuiteLoader.parse(
            """
            name: slow
            cases:
              - id: slow
                prompt: p
                expect:
            \(checks)
            """
        )
        let provider = ScriptedProvider(answers: ["slow": [Generation(text: slowText, latency: 0.1)]])
        let started = Date()
        let result = await Runner(provider: provider).run(suite)
        let elapsed = Date().timeIntervalSince(started)

        let details = result.cases[0].samples[0].checks.map(\.detail)
        let gaveUp = tags.prefix(2).map { PatternMatch.detail(.timedOut, pattern: slowPattern($0)) }
        let notTried = tags.dropFirst(2).map { PatternMatch.detail(.budgetSpent, pattern: slowPattern($0)) }
        #expect(details == gaveUp + notTried)
        #expect(elapsed < Double(PatternBudget.maximumGiveUps) * PatternMatch.timeLimit + 1.5)
        #expect(
            notTried.first == """
                did not try /^(e+)+$|run-3/: fmdrift already gave up on 2 regular expressions or spent \
                30.00 s matching them; simplify the patterns that backtrack
                """
        )
    }

    /// Runners given the same budget share it: the second suite does not get two more give-ups.
    @Test func sharesABudgetBetweenRunners() async throws {
        func suite(_ name: String) throws -> Suite {
            try SuiteLoader.parse(
                """
                name: \(name)
                cases:
                  - id: slow
                    prompt: p
                    expect:
                      - matches: "\(slowPattern("\(name)-1"))"
                      - matches: "\(slowPattern("\(name)-2"))"
                """
            )
        }
        let provider = ScriptedProvider(answers: ["slow": [Generation(text: slowText, latency: 0.1)]])
        let budget = PatternBudget()
        let started = Date()
        let first = await Runner(provider: provider, patterns: budget).run(try suite("shared-a"))
        let second = await Runner(provider: provider, patterns: budget).run(try suite("shared-b"))
        let elapsed = Date().timeIntervalSince(started)

        #expect(
            first.cases[0].samples[0].checks.map(\.detail)
                == ["shared-a-1", "shared-a-2"].map { PatternMatch.detail(.timedOut, pattern: slowPattern($0)) })
        #expect(
            second.cases[0].samples[0].checks.map(\.detail)
                == ["shared-b-1", "shared-b-2"].map { PatternMatch.detail(.budgetSpent, pattern: slowPattern($0)) })
        #expect(elapsed < Double(PatternBudget.maximumGiveUps) * PatternMatch.timeLimit + 1.5)
    }
}
