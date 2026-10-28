import Foundation

/// Markdown for pull request comments and CI job summaries (`$GITHUB_STEP_SUMMARY`).
public enum MarkdownReport {
    public static func run(_ result: RunResult) -> String {
        let environment = result.environment
        var lines = [
            "## fmdrift: \(TextSafety.markdown(result.suite))",
            "",
            "\(result.passedCount) of \(result.cases.count) cases passed · \(result.generationCount) generations in \(Format.duration(result.duration)) · \(TextSafety.markdown(environment.osLabel))\(environment.chip.isEmpty ? "" : " · \(TextSafety.markdown(environment.chip))") · \(TerminalReport.providerLabel(environment))",
            "",
            "| | Case | Passing | Agreement | Median latency | Output |",
            "| --- | --- | --- | --- | --- | --- |",
        ]
        for testCase in result.cases {
            let latency = testCase.medianLatency.map(Format.duration) ?? "–"
            lines.append(
                "| \(testCase.passed ? "✅" : "❌") | \(TextSafety.markdown(testCase.id)) | \(testCase.passCount)/\(testCase.samples.count) | \(Format.percent(testCase.agreement)) | \(latency) | \(TextSafety.markdown(Excerpt.of(testCase.representativeOutput, limit: 80))) |"
            )
        }
        let failed = result.cases.filter { !$0.passed }
        if !failed.isEmpty {
            lines.append("")
            lines.append("### Failed cases")
            for testCase in failed {
                lines.append("")
                lines.append("**\(TextSafety.markdown(testCase.id))**")
                lines.append("")
                for failure in TerminalReport.failedChecks(testCase) {
                    let detail = failure.detail.map { ": \(TextSafety.markdown($0))" } ?? ""
                    lines.append(
                        "- \(TextSafety.markdown(failure.label))\(detail) (\(failure.count) of \(testCase.samples.count))"
                    )
                }
                for advice in Advice.forFailedCase(testCase) {
                    lines.append("- How to fix: \(advice.text) [\(advice.source.title)](\(advice.source.url))")
                }
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }

    public static func diff(_ diff: SnapshotDiff) -> String {
        var lines = [
            "## fmdrift diff: \(TextSafety.markdown(diff.current.suite))",
            "",
            "| | Environment |",
            "| --- | --- |",
            "| Baseline | \(TextSafety.markdown(TerminalReport.sideLabel(diff.baseline))) |",
            "| Current | \(TextSafety.markdown(TerminalReport.sideLabel(diff.current))) |",
            "",
            TextSafety.markdown(TerminalReport.diffSummary(diff, style: .plain)),
            "",
            "| Status | Case | Passing | Median latency | Note |",
            "| --- | --- | --- | --- | --- |",
        ]
        for change in diff.cases {
            var passing = "–"
            var latency = "–"
            if let before = change.baseline, let after = change.current {
                passing = "\(Format.percent(before.passRate)) → \(Format.percent(after.passRate))"
                if let old = before.medianLatency, let new = after.medianLatency {
                    latency = "\(Format.duration(old)) → \(Format.duration(new))"
                    if let delta = Format.change(from: old, to: new) { latency += " (\(delta))" }
                }
            } else if let only = change.current ?? change.baseline {
                passing = Format.percent(only.passRate)
            }
            var notes: [String] = []
            if change.slower { notes.append("slower than allowed") }
            if change.inputChanged { notes.append("input changed") }
            if !change.newlyFailingChecks.isEmpty {
                notes.append("newly failing: " + change.newlyFailingChecks.joined(separator: "; "))
            }
            lines.append(
                "| \(statusLabel(change.status)) | \(TextSafety.markdown(change.id)) | \(passing) | \(latency) | \(TextSafety.markdown(notes.joined(separator: " · "))) |"
            )
        }
        let changedOutputs = diff.cases.filter {
            guard let before = $0.baseline?.output, let after = $0.current?.output else { return false }
            return before != after
        }
        if !changedOutputs.isEmpty {
            lines.append("")
            lines.append("### Outputs that changed")
            for change in changedOutputs {
                lines.append("")
                lines.append("**\(TextSafety.markdown(change.id))**")
                lines.append("")
                lines.append(
                    "- Baseline: \(TextSafety.markdown(Excerpt.of(change.baseline?.output ?? "", limit: 300)))")
                lines.append("- Current: \(TextSafety.markdown(Excerpt.of(change.current?.output ?? "", limit: 300)))")
            }
        }
        if diff.count(.regressed) > 0 {
            lines.append("")
            lines.append(
                "How to fix a regression: \(Advice.regression.text) [\(Advice.regression.source.title)](\(Advice.regression.source.url))"
            )
        }
        return lines.joined(separator: "\n") + "\n"
    }

    static func statusLabel(_ status: SnapshotDiff.Status) -> String {
        switch status {
        case .regressed: "❌ regressed"
        case .fixed: "✅ fixed"
        case .stillFailing: "❌ still failing"
        case .changed: "⚠️ changed"
        case .unchanged: "unchanged"
        case .added: "added"
        case .removed: "removed"
        }
    }
}

/// JUnit XML, which CI systems show as test results: one test suite per suite file, one test
/// case per case.
public enum JUnitReport {
    public static func run(_ result: RunResult) -> String {
        runs([result])
    }

    public static func runs(_ results: [RunResult]) -> String {
        let tests = results.reduce(0) { $0 + $1.cases.count }
        let failures = results.reduce(0) { $0 + $1.failedCount }
        let time = results.reduce(0) { $0 + $1.duration }
        var lines = [
            #"<?xml version="1.0" encoding="UTF-8"?>"#,
            #"<testsuites name="fmdrift" tests="\#(tests)" failures="\#(failures)" time="\#(seconds(time))">"#,
        ]
        for result in results {
            lines.append(contentsOf: suite(result))
        }
        lines.append("</testsuites>")
        return lines.joined(separator: "\n") + "\n"
    }

    static func suite(_ result: RunResult) -> [String] {
        let failures = result.failedCount
        let suiteName = TextSafety.xml(result.suite)
        var lines = [
            #"  <testsuite name="\#(suiteName)" tests="\#(result.cases.count)" failures="\#(failures)" errors="0" skipped="0" time="\#(seconds(result.duration))">"#,
            "    <properties>",
        ]
        let environment = result.environment
        let properties: [(String, String)] = [
            ("fmdrift.version", result.fmdriftVersion),
            ("os", environment.osLabel),
            ("os.build", environment.osBuild),
            ("hardware", environment.hardware),
            ("chip", environment.chip),
            ("locale", environment.locale),
            ("provider", environment.provider),
            ("model.availability", environment.modelAvailability),
        ]
        for (name, value) in properties where !value.isEmpty {
            lines.append(#"      <property name="\#(name)" value="\#(TextSafety.xml(value))"/>"#)
        }
        lines.append("    </properties>")
        for testCase in result.cases {
            let time = seconds(testCase.samples.reduce(0) { $0 + $1.generation.latency })
            let open =
                #"    <testcase classname="\#(suiteName)" name="\#(TextSafety.xml(testCase.id))" time="\#(time)""#
            if testCase.passed {
                lines.append(open + "/>")
                continue
            }
            lines.append(open + ">")
            let checks = TerminalReport.failedChecks(testCase)
            let message =
                checks.first.map { "\($0.label)\($0.detail.map { ": \($0)" } ?? "")" }
                ?? "\(testCase.passCount) of \(testCase.samples.count) responses passed"
            var body = [
                "\(testCase.passCount) of \(testCase.samples.count) responses passed; \(Format.percent(testCase.minPassRate)) needed."
            ]
            for check in checks {
                body.append(
                    "\(check.label)\(check.detail.map { ": \($0)" } ?? "") (\(check.count) of \(testCase.samples.count))"
                )
            }
            for advice in Advice.forFailedCase(testCase) {
                body.append("How to fix: \(advice.text) \(advice.source.url)")
            }
            lines.append(
                #"      <failure message="\#(TextSafety.xml(message))" type="fmdrift.check">\#(TextSafety.xml(body.joined(separator: "\n")))</failure>"#
            )
            lines.append(#"      <system-out>\#(TextSafety.xml(testCase.representativeOutput))</system-out>"#)
            lines.append("    </testcase>")
        }
        lines.append("  </testsuite>")
        return lines
    }

    static func seconds(_ value: Double) -> String {
        String(format: "%.3f", locale: Locale(identifier: "en_US_POSIX"), value)
    }
}

/// JSON output for `--json`: the run result or the diff, pretty-printed with sorted keys.
public enum JSONReport {
    public static func run(_ result: RunResult) -> String {
        String(decoding: SnapshotStore.encode(result), as: UTF8.self)
    }

    public static func diff(_ diff: SnapshotDiff) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        let data = (try? encoder.encode(diff)) ?? Data()
        return String(decoding: data, as: UTF8.self) + "\n"
    }
}
