import Foundation
import Testing

@testable import FMDriftKit

/// Builds results without running anything.
enum Make {
    static let environment26 = RunEnvironment(
        platform: "macOS",
        osVersion: "26.4",
        osBuild: "25E246",
        hardware: "Mac16,10",
        chip: "Apple M4",
        locale: "en_US",
        provider: "system",
        modelAvailability: "available",
        contextSize: 4096
    )
    static let environment27 = RunEnvironment(
        platform: "macOS",
        osVersion: "27.0.1",
        osBuild: "26A434",
        hardware: "Mac16,10",
        chip: "Apple M4",
        locale: "en_US",
        provider: "system",
        modelAvailability: "available",
        contextSize: 4096
    )

    static func testCase(_ id: String, prompt: String = "p", checks: [Assertion] = [Assertion(.contains(["ok"]))])
        -> TestCase
    {
        TestCase(id: id, prompt: prompt, assertions: checks)
    }

    static func result(
        _ testCase: TestCase,
        outputs: [String],
        latency: Double = 0.5,
        minPassRate: Double = 1
    ) -> CaseResult {
        var testCase = testCase
        testCase.minPassRate = minPassRate
        let samples = outputs.map { output in
            let generation = Generation(text: output, latency: latency, outputTokens: output.count / 4 + 1)
            return SampleResult(generation: generation, checks: Evaluator.evaluate(generation, for: testCase))
        }
        return CaseResult(
            id: testCase.id,
            prompt: testCase.prompt,
            fingerprint: testCase.fingerprint,
            settings: testCase.settings,
            schema: nil,
            minPassRate: minPassRate,
            samples: samples
        )
    }

    static func run(_ cases: [CaseResult], environment: RunEnvironment, at seconds: Double = 1_793_000_000)
        -> RunResult
    {
        RunResult(
            suite: "demo",
            recordedAt: Date(timeIntervalSince1970: seconds),
            duration: 3.25,
            environment: environment,
            cases: cases,
            fmdriftVersion: "0.1.0"
        )
    }
}

@Suite("Snapshot files")
struct SnapshotStoreTests {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("fmdrift-\(UUID().uuidString)")

    @Test func writesReadsAndNamesSnapshots() throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        let run = Make.run([Make.result(Make.testCase("a"), outputs: ["ok", "ok"])], environment: Make.environment27)
        let url = SnapshotStore.url(in: directory, suite: "demo", environment: run.environment)
        #expect(url.path.hasSuffix("/demo/macOS-27.0.1-26A434.json"))
        try SnapshotStore.write(run, to: url)
        #expect(try SnapshotStore.read(contentsOf: url) == run)

        let text = String(decoding: SnapshotStore.encode(run), as: UTF8.self)
        #expect(text.hasPrefix("{\n  \"cases\" : ["))
        #expect(text.hasSuffix("}\n"))
        #expect(text.contains(#""recordedAt" : "2026-10-26T"#))
    }

    @Test func explainsUnreadableFiles() throws {
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        func message(_ text: String) -> String {
            let url = directory.appendingPathComponent("s.json")
            try? text.write(to: url, atomically: true, encoding: .utf8)
            do {
                _ = try SnapshotStore.read(contentsOf: url)
                return "no error"
            } catch {
                return error.message
            }
        }
        #expect(message("[]") == "is not a JSON object; is it an fmdrift snapshot?")
        #expect(message("{}") == "has no `format`; is it an fmdrift snapshot?")
        #expect(
            message(#"{"format": 2}"#) == "uses snapshot format 2; this fmdrift reads format 1. Update fmdrift."
        )
        #expect(message(#"{"format": 1}"#) == "is not a valid snapshot (missing `fmdriftVersion` at the top level)")
        #expect(message(String(repeating: "[", count: 70)) == "nests deeper than 64 levels")
        #expect(
            message(
                #"{"format": 1, "fmdriftVersion": "0.1.0", "suite": "s", "recordedAt": "2026-10-28T00:00:00Z", "duration": 1, "environment": {}, "cases": []}"#
            )
                == "is not a valid snapshot (missing `platform` at $.environment)"
        )
        do {
            _ = try SnapshotStore.read(contentsOf: directory.appendingPathComponent("missing.json"))
            Issue.record("expected an error")
        } catch {
            #expect(error.message.hasPrefix("cannot be read"))
        }
    }
}

@Suite("Snapshot diffs")
struct SnapshotDiffTests {
    let stable = Make.testCase("stable")
    let reworded = Make.testCase("reworded")
    let breaking = Make.testCase("breaking", checks: [Assertion(.contains(["ok"])), Assertion(.maxLength(10))])
    let healing = Make.testCase("healing")
    let broken = Make.testCase("broken")
    let gone = Make.testCase("gone")
    let fresh = Make.testCase("fresh")

    func diff(latencyIncrease: Double? = nil) -> SnapshotDiff {
        let baseline = Make.run(
            [
                Make.result(stable, outputs: ["ok"]),
                Make.result(reworded, outputs: ["ok, sure"]),
                Make.result(breaking, outputs: ["ok"]),
                Make.result(healing, outputs: ["no"]),
                Make.result(broken, outputs: ["no"]),
                Make.result(gone, outputs: ["ok"]),
            ],
            environment: Make.environment26
        )
        var changedPrompt = reworded
        changedPrompt.prompt = "p, reworded"
        let current = Make.run(
            [
                Make.result(stable, outputs: ["ok"], latency: 0.9),
                Make.result(changedPrompt, outputs: ["ok, certainly"]),
                Make.result(breaking, outputs: ["ok, but this is much longer"]),
                Make.result(healing, outputs: ["ok"]),
                Make.result(broken, outputs: ["no"]),
                Make.result(fresh, outputs: ["ok"]),
            ],
            environment: Make.environment27
        )
        return SnapshotDiff(baseline: baseline, current: current, latencyIncrease: latencyIncrease)
    }

    @Test func classifiesEveryCase() {
        let diff = diff()
        let statuses = Dictionary(uniqueKeysWithValues: diff.cases.map { ($0.id, $0.status) })
        #expect(
            statuses == [
                "stable": .unchanged, "reworded": .changed, "breaking": .regressed, "healing": .fixed,
                "broken": .stillFailing, "fresh": .added, "gone": .removed,
            ]
        )
        #expect(diff.cases.map(\.id) == ["stable", "reworded", "breaking", "healing", "broken", "fresh", "gone"])
        #expect(diff.cases[1].inputChanged)
        #expect(!diff.cases[0].inputChanged)
        #expect(diff.cases[2].newlyFailingChecks == ["length ≤ 10"])
        #expect(diff.cases[2].baseline?.output == "ok")
        #expect(diff.cases[2].current?.output == "ok, but this is much longer")
        #expect(diff.baseline.environment.osVersion == "26.4")
        #expect(diff.current.environment.osVersion == "27.0.1")
        #expect(diff.count(.regressed) == 1)
    }

    @Test func appliesTheFailurePolicy() {
        let diff = diff()
        #expect(diff.fails(under: .regressed))
        #expect(diff.fails(under: .changed))
        #expect(!diff.fails(under: .never))

        let same = Make.run([Make.result(stable, outputs: ["ok"])], environment: Make.environment26)
        let quiet = SnapshotDiff(baseline: same, current: same)
        #expect(!quiet.fails(under: .regressed))
        #expect(!quiet.fails(under: .changed))

        let reworded = Make.run([Make.result(stable, outputs: ["ok!"])], environment: Make.environment27)
        let changed = SnapshotDiff(baseline: same, current: reworded)
        #expect(!changed.fails(under: .regressed))
        #expect(changed.fails(under: .changed))
    }

    @Test func marksCasesSlowerThanAllowed() {
        #expect(diff().slowerCount == 0)
        let strict = diff(latencyIncrease: 0.5)
        #expect(strict.cases.filter(\.slower).map(\.id) == ["stable"])
        #expect(strict.fails(under: .regressed))
        #expect(diff(latencyIncrease: 0.9).slowerCount == 0)
    }

    @Test func aDroppingPassRateIsAChangeEvenWhenTheCaseStillPasses() {
        let flaky = Make.testCase("flaky")
        let before = Make.run(
            [Make.result(flaky, outputs: ["ok", "ok", "ok"], minPassRate: 0.5)], environment: Make.environment26)
        let after = Make.run(
            [Make.result(flaky, outputs: ["ok", "ok", "no"], minPassRate: 0.5)], environment: Make.environment27)
        let change = SnapshotDiff(baseline: before, current: after).cases[0]
        #expect(change.status == .changed)
        #expect(change.newlyFailingChecks == [#"contains "ok""#])
    }
}

@Suite("Agreement and regression advice")
struct DiffAdviceTests {
    @Test func aFallingAgreementIsAChange() {
        let triage = Make.testCase("triage")
        let before = Make.run(
            [Make.result(triage, outputs: ["ok 1", "ok 1", "ok 1"])], environment: Make.environment27)
        let after = Make.run([Make.result(triage, outputs: ["ok 1", "ok 2", "ok 3"])], environment: Make.environment27)
        let change = SnapshotDiff(baseline: before, current: after).cases[0]
        #expect(change.status == .changed)
        #expect(change.baseline?.agreement == 1)
    }

    @Test func regressionAdviceFollowsTheCause() {
        let testCase = Make.testCase("a")
        let passing = Make.run([Make.result(testCase, outputs: ["ok"])], environment: Make.environment26)
        let failing = Make.run([Make.result(testCase, outputs: ["no"])], environment: Make.environment27)
        let newModel = SnapshotDiff(baseline: passing, current: failing).cases[0]
        #expect(Advice.forRegression(newModel, sameOSBuild: false).source == .updatingPrompts)
        #expect(Advice.forRegression(newModel, sameOSBuild: true).source == .prompting)

        var edited = testCase
        edited.prompt = "p, edited"
        let editedRun = Make.run([Make.result(edited, outputs: ["no"])], environment: Make.environment26)
        let editChange = SnapshotDiff(baseline: passing, current: editedRun).cases[0]
        #expect(editChange.inputChanged)
        #expect(Advice.forRegression(editChange, sameOSBuild: true).source == .evaluating)
    }
}

@Suite("Word diffs")
struct WordDiffTests {
    @Test func marksRemovedAndAddedWords() throws {
        let segments = try #require(WordDiff.segments(from: "The capital is Paris.", to: "The capital city is Paris!"))
        #expect(
            segments == [
                .init(operation: .equal, text: "The capital "),
                .init(operation: .added, text: "city "),
                .init(operation: .equal, text: "is "),
                .init(operation: .removed, text: "Paris."),
                .init(operation: .added, text: "Paris!"),
            ]
        )
    }

    @Test func rebuildsBothSides() throws {
        let old = "one two  three\nfour"
        let new = "one 2 three\nfour five"
        let segments = try #require(WordDiff.segments(from: old, to: new))
        #expect(segments.filter { $0.operation != .added }.map(\.text).joined() == old)
        #expect(segments.filter { $0.operation != .removed }.map(\.text).joined() == new)
        #expect(WordDiff.segments(from: "", to: "") == [])
        #expect(WordDiff.segments(from: "", to: "a b") == [.init(operation: .added, text: "a b")])
    }

    @Test func refusesVeryLongTexts() {
        let long = String(repeating: "word ", count: WordDiff.maximumWords + 1)
        #expect(WordDiff.segments(from: long, to: "short") == nil)
    }
}
