import Foundation

/// ANSI styling, or none.
public struct TerminalStyle: Sendable {
    public var color: Bool

    public init(color: Bool) {
        self.color = color
    }

    public static let plain = TerminalStyle(color: false)

    func wrap(_ text: String, _ code: String) -> String {
        color ? "\u{1B}[\(code)m\(text)\u{1B}[0m" : text
    }

    public func bold(_ text: String) -> String { wrap(text, "1") }
    public func dim(_ text: String) -> String { wrap(text, "2") }
    public func red(_ text: String) -> String { wrap(text, "31") }
    public func green(_ text: String) -> String { wrap(text, "32") }
    public func yellow(_ text: String) -> String { wrap(text, "33") }
    public func blue(_ text: String) -> String { wrap(text, "34") }

    /// Color when standard output is a terminal and neither `NO_COLOR` nor `TERM=dumb` is set;
    /// `CLICOLOR_FORCE=1` colors output that goes to a file or pipe.
    public static func detect(environment: [String: String] = ProcessInfo.processInfo.environment) -> TerminalStyle {
        if let noColor = environment["NO_COLOR"], !noColor.isEmpty { return .plain }
        if let force = environment["CLICOLOR_FORCE"], !force.isEmpty, force != "0" { return TerminalStyle(color: true) }
        if environment["TERM"] == "dumb" { return .plain }
        return TerminalStyle(color: isatty(STDOUT_FILENO) == 1)
    }
}

/// The human-readable report printed by `run`, `record` and `diff`.
public enum TerminalReport {
    // MARK: Runs

    public static func run(_ result: RunResult, style: TerminalStyle) -> String {
        var lines = [header(result, style: style), ""]
        let width = min(28, max(8, result.cases.map(\.id.count).max() ?? 8))
        for testCase in result.cases {
            lines.append(contentsOf: caseLines(testCase, idWidth: width, style: style))
        }
        lines.append("")
        lines.append(summary(result, style: style))
        return lines.joined(separator: "\n") + "\n"
    }

    public static func header(_ result: RunResult, style: TerminalStyle) -> String {
        let environment = result.environment
        var parts = [
            "fmdrift \(TextSafety.terminal(result.fmdriftVersion))", "suite \(TextSafety.terminal(result.suite))",
            TextSafety.terminal(environment.osLabel),
        ]
        if !environment.chip.isEmpty { parts.append(TextSafety.terminal(environment.chip)) }
        parts.append(providerLabel(environment))
        return style.bold(parts.joined(separator: " · "))
    }

    public static func providerLabel(_ environment: RunEnvironment) -> String {
        switch environment.provider {
        case "system": "on-device model"
        case "replay": "replayed responses"
        default: TextSafety.terminal(environment.provider)
        }
    }

    static func caseLines(_ result: CaseResult, idWidth: Int, style: TerminalStyle) -> [String] {
        let badge = result.passed ? style.green(" PASS ") : style.red(" FAIL ")
        var figures = ["\(result.passCount)/\(result.samples.count)"]
        if result.samples.count > 1 { figures.append("agreement \(Format.percent(result.agreement))") }
        if let latency = result.medianLatency {
            figures.append((result.samples.count > 1 ? "median " : "") + Format.duration(latency))
        }
        let id = TextSafety.terminal(result.id).padding(toLength: idWidth, withPad: " ", startingAt: 0)
        var lines = ["\(badge) \(id)  \(figures.joined(separator: "   "))"]
        let indent = String(repeating: " ", count: 7)
        for note in result.notes {
            lines.append(indent + style.yellow("note: ") + TextSafety.terminal(note))
        }
        guard !result.passed else { return lines }

        for failure in failedChecks(result) {
            let share = result.samples.count > 1 ? " (\(failure.count) of \(result.samples.count))" : ""
            let detail = failure.detail.map { " — " + TextSafety.terminal($0) } ?? ""
            lines.append(indent + style.red("✗ ") + TextSafety.terminal(failure.label) + detail + style.dim(share))
        }
        if result.minPassRate < 1 {
            lines.append(
                indent
                    + style.dim(
                        "needs \(Format.percent(result.minPassRate)) passing, got \(Format.percent(result.passRate))"
                    )
            )
        }
        for advice in Advice.forFailedCase(result) {
            lines.append(indent + style.blue("How to fix: ") + advice.text)
            lines.append(indent + "  " + style.dim(advice.source.url))
        }
        return lines
    }

    /// Failed checks of a case, grouped by label, in the order they first failed.
    public static func failedChecks(_ result: CaseResult) -> [(label: String, detail: String?, count: Int)] {
        var order: [String] = []
        var details: [String: String?] = [:]
        var counts: [String: Int] = [:]
        for sample in result.samples {
            for check in sample.checks where check.status == .failed {
                if counts[check.label] == nil {
                    order.append(check.label)
                    details[check.label] = check.detail
                }
                counts[check.label, default: 0] += 1
            }
        }
        return order.map { ($0, details[$0] ?? nil, counts[$0] ?? 0) }
    }

    static func summary(_ result: RunResult, style: TerminalStyle) -> String {
        let cases = Format.count(result.cases.count, "case", "cases")
        let passed = style.green("\(result.passedCount) passed")
        let failed = result.failedCount > 0 ? style.red("\(result.failedCount) failed") : "0 failed"
        return "\(cases) · \(passed) · \(failed) · \(work(result))"
    }

    /// `15 generations in 9.79 s`. A replay generates nothing: it checks recorded responses,
    /// and its time is only the time to check them.
    public static func work(_ result: RunResult) -> String {
        let duration = Format.duration(result.duration)
        if result.environment.provider == "replay" {
            let responses = Format.count(result.generationCount, "recorded response", "recorded responses")
            return "\(responses) checked in \(duration)"
        }
        return "\(Format.count(result.generationCount, "generation", "generations")) in \(duration)"
    }

    // MARK: Diffs

    public static func diff(_ diff: SnapshotDiff, style: TerminalStyle, showUnchanged: Bool = false) -> String {
        var lines = [
            style.bold("fmdrift diff · suite \(TextSafety.terminal(diff.current.suite))"),
            "  baseline  \(sideLabel(diff.baseline))",
            "  current   \(sideLabel(diff.current))",
        ]
        if diff.baseline.suite != diff.current.suite {
            lines.append(
                style.yellow("  note: ")
                    + "the snapshots are of different suites (\(TextSafety.terminal(diff.baseline.suite)) and \(TextSafety.terminal(diff.current.suite)))"
            )
        }
        lines.append("")
        let width = min(28, max(8, diff.cases.map(\.id.count).max() ?? 8))
        var unchanged = 0
        let sameOSBuild = diff.baseline.environment.snapshotName == diff.current.environment.snapshotName
        for change in diff.cases {
            if change.status == .unchanged, !change.slower, !showUnchanged {
                unchanged += 1
                continue
            }
            lines.append(contentsOf: changeLines(change, idWidth: width, sameOSBuild: sameOSBuild, style: style))
        }
        if unchanged > 0 {
            lines.append(style.dim(" UNCHANGED  \(unchanged == 1 ? "1 case" : "\(unchanged) cases")"))
        }
        lines.append("")
        lines.append(diffSummary(diff, style: style))
        return lines.joined(separator: "\n") + "\n"
    }

    public static func sideLabel(_ side: SnapshotDiff.Side) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        var label = TextSafety.terminal(side.environment.osLabel)
        if !side.environment.chip.isEmpty { label += " · \(TextSafety.terminal(side.environment.chip))" }
        label += " · recorded \(formatter.string(from: side.recordedAt))"
        if side.environment.provider != "system" { label += " · \(providerLabel(side.environment))" }
        return label
    }

    static func badge(_ status: SnapshotDiff.Status, style: TerminalStyle) -> String {
        let text: String
        switch status {
        case .regressed: return style.red(" REGRESSED ")
        case .fixed: return style.green(" FIXED     ")
        case .stillFailing: return style.red(" FAILING   ")
        case .changed: text = " CHANGED   "
        case .unchanged: text = " UNCHANGED "
        case .added: text = " ADDED     "
        case .removed: text = " REMOVED   "
        }
        return style.yellow(text)
    }

    static func changeLines(
        _ change: SnapshotDiff.CaseChange,
        idWidth: Int,
        sameOSBuild: Bool,
        style: TerminalStyle
    ) -> [String] {
        let id = TextSafety.terminal(change.id).padding(toLength: idWidth, withPad: " ", startingAt: 0)
        var figures: [String] = []
        if let before = change.baseline, let after = change.current {
            figures.append("\(Format.percent(before.passRate)) → \(Format.percent(after.passRate)) passing")
            if abs(before.agreement - after.agreement) > 1e-9 {
                figures.append("agreement \(Format.percent(before.agreement)) → \(Format.percent(after.agreement))")
            }
            if let old = before.medianLatency, let new = after.medianLatency {
                var latency = "\(Format.duration(old)) → \(Format.duration(new))"
                if let delta = Format.change(from: old, to: new) { latency += " (\(delta))" }
                figures.append(change.slower ? style.red(latency) : latency)
            }
        } else if let only = change.current ?? change.baseline {
            figures.append("\(Format.percent(only.passRate)) passing")
        }
        var lines = ["\(badge(change.status, style: style)) \(id)  \(figures.joined(separator: "   "))"]
        let indent = String(repeating: " ", count: 12)
        if change.slower {
            lines.append(indent + style.red("slower than allowed"))
        }
        if change.inputChanged {
            lines.append(
                indent + style.yellow("note: ")
                    + "the prompt, instructions, options or schema changed between the runs"
            )
        }
        if !change.newlyFailingChecks.isEmpty {
            let checks = change.newlyFailingChecks.map(TextSafety.terminal).joined(separator: "; ")
            lines.append(indent + "newly failing: " + checks)
        }
        if let before = change.baseline?.output, let after = change.current?.output, before != after {
            lines.append(indent + "output: " + outputDiff(before, after, style: style))
        }
        if change.status == .regressed {
            let advice = Advice.forRegression(change, sameOSBuild: sameOSBuild)
            lines.append(indent + style.blue("How to fix: ") + advice.text)
            lines.append(indent + "  " + style.dim(advice.source.url))
        }
        return lines
    }

    /// A word diff of two outputs, shortened to about 240 characters around the first change.
    static func outputDiff(_ old: String, _ new: String, style: TerminalStyle) -> String {
        guard let segments = WordDiff.segments(from: old, to: new) else {
            return
                "[-\(Excerpt.of(TextSafety.terminal(old), limit: 100))-] {+\(Excerpt.of(TextSafety.terminal(new), limit: 100))+}"
        }
        var text = ""
        var budget = 240
        var started = false
        for (index, segment) in segments.enumerated() {
            var piece = TextSafety.terminal(segment.text)
            if segment.operation == .equal {
                // Keep a little context before the first change and between changes.
                let isFirst = index == 0
                let isLast = index == segments.count - 1
                if isFirst, piece.count > 40 { piece = "…" + String(piece.suffix(40)) }
                if isLast, piece.count > 40 { piece = String(piece.prefix(40)) + "…" }
                if !isFirst, !isLast, piece.count > 80 {
                    piece = String(piece.prefix(38)) + " … " + String(piece.suffix(38))
                }
            }
            if budget <= 0 {
                text += "…"
                break
            }
            if piece.count > budget { piece = String(piece.prefix(budget)) + "…" }
            budget -= piece.count
            switch segment.operation {
            case .equal: text += piece
            // The markers stay in color too: the blue report theme does not separate red from green.
            case .removed: text += style.red("[-\(piece)-]")
            case .added: text += style.green("{+\(piece)+}")
            }
            started = true
        }
        return started ? text : ""
    }

    public static func diffSummary(_ diff: SnapshotDiff, style: TerminalStyle) -> String {
        var parts: [String] = []
        let regressed = diff.count(.regressed)
        parts.append(regressed > 0 ? style.red("\(regressed) regressed") : "0 regressed")
        parts.append("\(diff.count(.changed)) changed")
        parts.append("\(diff.count(.fixed)) fixed")
        if diff.count(.stillFailing) > 0 { parts.append("\(diff.count(.stillFailing)) still failing") }
        if diff.count(.added) > 0 { parts.append("\(diff.count(.added)) added") }
        if diff.count(.removed) > 0 { parts.append("\(diff.count(.removed)) removed") }
        parts.append("\(diff.count(.unchanged)) unchanged")
        if diff.slowerCount > 0 { parts.append(style.red("\(diff.slowerCount) slower")) }
        return parts.joined(separator: " · ")
    }
}
