import Foundation
import Testing

@testable import FMDriftKit

/// Compares text with a file under Fixtures/expected. With FMDRIFT_RECORD_EXPECTED=1 the file is
/// written instead, so a deliberate format change is one command and a reviewed git diff.
enum Expected {
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    static func check(_ text: String, named name: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
        let url = root.appendingPathComponent("Fixtures/expected/\(name)")
        if ProcessInfo.processInfo.environment["FMDRIFT_RECORD_EXPECTED"] == "1" {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try Data(text.utf8).write(to: url)
            return
        }
        let expected = try String(contentsOf: url, encoding: .utf8)
        #expect(text == expected, "differs from Fixtures/expected/\(name)", sourceLocation: sourceLocation)
    }
}

/// A run with every kind of outcome, built from fixed data so reports are byte-for-byte stable.
enum SampleRuns {
    static let summary = TestCase(
        id: "ticket-summary",
        prompt: "Summarize the ticket in one sentence.",
        settings: GenerationSettings(instructions: "You summarize support tickets."),
        assertions: [Assertion(.contains(["refund"]), ignoreCase: true), Assertion(.maxLatency(1))],
        repeatCount: 3,
        minPassRate: 1
    )
    static let capital = TestCase(
        id: "capital",
        prompt: "What is the capital of France?",
        assertions: [Assertion(.equals(.string("Paris")))]
    )
    static let sentimentSchema = JSONSchema.object(
        properties: [
            .init(
                name: "sentiment",
                schema: .string(enumValues: ["positive", "neutral", "negative"], pattern: nil, description: nil),
                isRequired: true
            )
        ],
        description: nil
    )
    static let sentiment = TestCase(
        id: "sentiment",
        prompt: "Classify: the app crashes.",
        schema: sentimentSchema,
        assertions: [Assertion(.equals(.string("negative")), path: ["sentiment"])]
    )
    static let unsafe = TestCase(
        id: "unsafe-request",
        prompt: "An unsafe request.",
        assertions: [Assertion(.refusal(true))]
    )
    static let guarded = TestCase(
        id: "news-summary",
        prompt: "Summarize this news article about a crime.",
        assertions: [Assertion(.maxLength(200))]
    )

    static func result(_ testCase: TestCase, _ generations: [Generation]) -> CaseResult {
        CaseResult(
            id: testCase.id,
            prompt: testCase.prompt,
            fingerprint: testCase.fingerprint,
            settings: testCase.settings,
            schema: testCase.schema?.jsonValue,
            minPassRate: testCase.minPassRate,
            samples: generations.map { SampleResult(generation: $0, checks: Evaluator.evaluate($0, for: testCase)) }
        )
    }

    static var baseline: RunResult {
        Make.run(
            [
                result(capital, [Generation(text: "Paris", latency: 0.412, outputTokens: 2, inputTokens: 18)]),
                result(
                    summary,
                    [
                        Generation(
                            text: "The customer wants a refund for a double charge.", latency: 0.82, outputTokens: 12),
                        Generation(
                            text: "The customer wants a refund for a double charge.", latency: 0.79, outputTokens: 12),
                        Generation(
                            text: "The customer asks for a refund after being charged twice.", latency: 0.85,
                            outputTokens: 13),
                    ]
                ),
                result(sentiment, [Generation(text: #"{"sentiment": "negative"}"#, latency: 0.6, outputTokens: 7)]),
                result(unsafe, [.failed(.guardrailViolation, "May contain unsafe content", latency: 0.2)]),
            ],
            environment: Make.environment26,
            at: 1_792_454_400
        )
    }

    static var current: RunResult {
        Make.run(
            [
                result(capital, [Generation(text: "The capital of France is Paris.", latency: 0.388, outputTokens: 8)]),
                result(
                    summary,
                    [
                        Generation(text: "The customer reports a double charge.", latency: 1.21, outputTokens: 8),
                        Generation(
                            text: "The customer wants a refund for a double charge.", latency: 0.97, outputTokens: 12),
                        Generation(text: "The customer reports a double charge.", latency: 1.3, outputTokens: 8),
                    ]
                ),
                result(sentiment, [Generation(text: #"{"sentiment": "negative"}"#, latency: 0.55, outputTokens: 7)]),
                result(unsafe, [.failed(.guardrailViolation, "May contain unsafe content", latency: 0.19)]),
                result(guarded, [.failed(.guardrailViolation, "May contain unsafe content", latency: 0.31)]),
            ],
            environment: Make.environment27,
            at: 1_793_059_200
        )
    }
}

@Suite("Reports")
struct ReportTests {
    @Test func terminalRunReport() throws {
        try Expected.check(TerminalReport.run(SampleRuns.current, style: .plain), named: "run.txt")
    }

    @Test func colouredTerminalRunReport() throws {
        let text = TerminalReport.run(SampleRuns.current, style: TerminalStyle(color: true))
        #expect(text.contains("\u{1B}[32m PASS \u{1B}[0m"))
        #expect(text.contains("\u{1B}[31m FAIL \u{1B}[0m"))
        let stripped = text.replacingOccurrences(of: "\u{1B}\\[[0-9;]*m", with: "", options: .regularExpression)
        #expect(stripped == TerminalReport.run(SampleRuns.current, style: .plain))
    }

    @Test func markdownRunReport() throws {
        try Expected.check(MarkdownReport.run(SampleRuns.current), named: "run.md")
    }

    @Test func junitRunReport() throws {
        let xml = JUnitReport.run(SampleRuns.current)
        try Expected.check(xml, named: "run.junit.xml")
        let document = try XMLDocument(xmlString: xml)
        #expect(try document.nodes(forXPath: "//testcase").count == 5)
        #expect(try document.nodes(forXPath: "//failure").count == 3)
    }

    @Test func jsonRunReport() throws {
        let json = JSONReport.run(SampleRuns.current)
        try Expected.check(json, named: "run.json")
        #expect(try SnapshotStore.decode(Data(json.utf8), path: "run.json") == SampleRuns.current)
    }

    @Test func terminalDiffReport() throws {
        let diff = SnapshotDiff(baseline: SampleRuns.baseline, current: SampleRuns.current, latencyIncrease: 0.5)
        try Expected.check(TerminalReport.diff(diff, style: .plain), named: "diff.txt")
        try Expected.check(
            TerminalReport.diff(diff, style: .plain, showUnchanged: true),
            named: "diff-all.txt"
        )
    }

    @Test func markdownAndJSONDiffReports() throws {
        let diff = SnapshotDiff(baseline: SampleRuns.baseline, current: SampleRuns.current, latencyIncrease: 0.5)
        try Expected.check(MarkdownReport.diff(diff), named: "diff.md")
        let json = JSONReport.diff(diff)
        try Expected.check(json, named: "diff.json")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        #expect(try decoder.decode(SnapshotDiff.self, from: Data(json.utf8)) == diff)
    }

    @Test func adviceCitesAppleDocumentation() {
        let current = SampleRuns.current
        let summary = Advice.forFailedCase(current.cases[1])
        #expect(summary.map(\.source) == [.performance, .prompting])
        let guarded = Advice.forFailedCase(current.cases[4])
        #expect(guarded.map(\.source) == [.permissiveGuardrails])
        for source in Advice.Source.all {
            #expect(source.url.hasPrefix("https://developer.apple.com/documentation/foundationmodels/"))
        }
    }
}

@Suite("Terminal color")
struct TerminalStyleTests {
    @Test func followsTheEnvironment() {
        #expect(TerminalStyle.detect(environment: ["NO_COLOR": "1", "CLICOLOR_FORCE": "1"]).color == false)
        #expect(TerminalStyle.detect(environment: ["CLICOLOR_FORCE": "1"]).color == true)
        #expect(TerminalStyle.detect(environment: ["TERM": "dumb"]).color == false)
        // Tests run with standard output redirected.
        #expect(TerminalStyle.detect(environment: ["CLICOLOR_FORCE": "0"]).color == (isatty(STDOUT_FILENO) == 1))
    }
}

@Suite("Untrusted text in reports")
struct TextSafetyTests {
    let hostile =
        "ok\u{1B}]52;c;ZXZpbA==\u{07}\u{1B}[2J\u{202E}gnp.exe\r\nnext | <b>x</b> `y` [z](javascript:1) & \u{0}"

    @Test func terminalShowsControlCharactersInsteadOfRunningThem() {
        let safe = TextSafety.terminal(hostile)
        #expect(!safe.unicodeScalars.contains { $0.value < 0x20 && $0 != "\t" })
        #expect(safe.contains(#"\u{1B}]52;c;ZXZpbA==\u{7}"#))
        #expect(safe.contains(#"\u{202E}gnp.exe"#))
        #expect(safe.contains("next"))
        #expect(!safe.contains("\n"))
    }

    @Test func markdownNeutralisesMarkup() {
        let safe = TextSafety.markdown(hostile)
        #expect(safe.contains(#"next \| &lt;b&gt;x&lt;/b&gt; \`y\` \[z\](javascript:1) &amp;"#))
        #expect(!safe.contains("\u{1B}"))
    }

    /// GitHub renders these as a mention, an issue link, an email link and two web links in a
    /// pull request comment; the escaped text renders as plain text (checked with GitHub's
    /// Markdown API, mode `gfm`).
    @Test func markdownStopsMentionsIssueLinksAndBareAddresses() {
        let text = "ask @octocat, see #12, mail a@b.example, https://evil.example/p or WWW.evil.example"
        #expect(
            TextSafety.markdown(text) == """
                ask @&#8203;octocat, see #&#8203;12, mail a@&#8203;b.example, https\\://evil.example/p or \
                WWW\\.evil.example
                """
        )
        // An ATX heading needs a space after its `#` signs.
        #expect(TextSafety.markdown("# title") == "#&#8203; title")
        #expect(TextSafety.markdown("time: 12:30, a.b") == "time: 12:30, a.b")
    }

    /// GitHub links `GH-3`, in any case, to issue or pull request 3 of the repository.
    @Test func markdownStopsGitHubIssueReferences() {
        #expect(
            TextSafety.markdown("see GH-3, gh-12 and Gh-7.")
                == "see GH-&#8203;3, gh-&#8203;12 and Gh-&#8203;7."
        )
        // Only a hyphen between `GH` and a digit; the space is invisible, so `high-5` gets one too.
        #expect(TextSafety.markdown("GH-x, GH 3, GH-, a-1") == "GH-x, GH 3, GH-, a-1")
    }

    /// GitHub renders `$…$`, `$$…$$` and `` $`…`$ `` as math, in table cells and paragraphs
    /// alike; a backslash or `&#36;` does not stop it, a `$` inside its own element does.
    @Test func markdownStopsMath() {
        let answer = #"$\huge\text{ALL TESTS PASSED}$ $$\color{green}{OK}$$ $`x`$ costs $5"#
        let safe = TextSafety.markdown(answer)
        #expect(!safe.replacingOccurrences(of: "<span>$</span>", with: "").contains("$"))
        #expect(safe.hasPrefix(#"<span>$</span>\\huge"#))
        #expect(safe.hasSuffix("costs <span>$</span>5"))
        var run = SampleRuns.current
        run.environment.chip = "$$\\Huge{M5}$$"
        run.cases = [SampleRuns.result(SampleRuns.capital, [Generation(text: answer, latency: 0.1)])]
        run.cases[0].id = "$x$"
        for report in [
            MarkdownReport.run(run), MarkdownReport.diff(SnapshotDiff(baseline: SampleRuns.current, current: run)),
        ] {
            #expect(!report.replacingOccurrences(of: "<span>$</span>", with: "").contains("$"))
        }
    }

    @Test func xmlEscapesMarkupAndInvalidCharacters() throws {
        let safe = TextSafety.xml(hostile)
        #expect(!safe.contains("<"))
        #expect(safe.contains(#"\u{0}"#))
        let document = try XMLDocument(xmlString: "<a b=\"\(safe)\">\(safe)</a>")
        #expect(document.rootElement()?.attribute(forName: "b")?.stringValue?.contains("<b>x</b>") == true)
    }

    /// Characters that print as nothing, or break a line in some log viewers.
    @Test(arguments: [
        0x2028, 0x2029, 0x00AD, 0x180E, 0x2061, 0x2064, 0x206A, 0x206F, 0xFFF9, 0xFFFB, 0xE0000, 0xE0001,
        0xE0041, 0xE007F,
    ])
    func escapesInvisibleCharacters(value: UInt32) throws {
        let scalar = try #require(Unicode.Scalar(value))
        let text = "a\(Character(scalar))b"
        let escape = "\\u{\(String(value, radix: 16, uppercase: true))}"
        #expect(TextSafety.terminal(text) == "a\(escape)b")
        #expect(TextSafety.xml(text) == "a\(escape)b")
        // Markdown escapes the backslash of the escape too.
        #expect(TextSafety.markdown(text) == "a\\\(escape)b")
    }

    @Test func reportsEscapeHostileSnapshotFields() {
        // A snapshot arrives with a pull request; every string in it is untrusted.
        var run = SampleRuns.current
        run.fmdriftVersion = "0.1.0\u{1B}]8;;https://example.invalid\u{7}"
        run.environment.provider = "<img src=x onerror=alert(1)>\u{1B}[2J"
        run.environment.osVersion = "27\u{202E}"
        let terminal = TerminalReport.run(run, style: .plain)
        #expect(!terminal.contains("\u{1B}"))
        #expect(!terminal.contains("\u{202E}"))
        let markdown = MarkdownReport.run(run)
        #expect(!markdown.contains("<img"))
        #expect(!markdown.contains("\u{1B}"))
        let junit = JUnitReport.run(run)
        #expect((try? XMLDocument(xmlString: junit)) != nil)
        let diff = TerminalReport.diff(SnapshotDiff(baseline: run, current: SampleRuns.current), style: .plain)
        #expect(!diff.contains("\u{1B}"))
    }

    /// JSON stays valid with these raw, but `jq -r` prints them to the terminal: U+009B is a
    /// one-byte CSI, U+202E reorders text, U+2028 breaks lines in some viewers, and tag
    /// characters spell out hidden text.
    @Test func jsonEscapesHiddenCharacters() throws {
        var run = SampleRuns.current
        let text = "a\u{9B}2Jb\u{202E}c\u{2028}d\u{7F}e\u{E0041}f\u{1B}g é ✓"
        run.cases = [SampleRuns.result(SampleRuns.capital, [Generation(text: text, latency: 0.1)])]
        run.environment.chip = "M\u{202E}"
        let json = JSONReport.run(run)
        for value: UInt32 in [0x9B, 0x202E, 0x2028, 0x7F, 0xE0041, 0x1B] {
            #expect(!json.unicodeScalars.contains { $0.value == value })
        }
        #expect(json.contains(#""text" : "a\u009b2Jb\u202ec\u2028d\u007fe\udb40\udc41f\u001bg é ✓""#))
        #expect(json.contains(#""chip" : "M\u202e""#))
        // Read back, the text is unchanged.
        #expect(try SnapshotStore.decode(Data(json.utf8), path: "run.json") == run)
        let diff = JSONReport.diff(SnapshotDiff(baseline: SampleRuns.current, current: run))
        #expect(!diff.unicodeScalars.contains { $0.value == 0x9B || $0.value == 0x202E })
        #expect(diff.contains(#"\u009b"#))
    }

    @Test func reportsEscapeHostileOutputs() {
        var run = SampleRuns.current
        let testCase = SampleRuns.capital
        run.cases = [SampleRuns.result(testCase, [Generation(text: hostile, latency: 0.1)])]
        let terminal = TerminalReport.run(run, style: .plain)
        #expect(!terminal.contains("\u{1B}"))
        #expect(!terminal.contains("\u{202E}"))
        let markdown = MarkdownReport.run(run)
        #expect(!markdown.contains("<b>"))
        let junit = JUnitReport.run(run)
        #expect((try? XMLDocument(xmlString: junit)) != nil)
    }
}
