import Foundation
import Testing

@testable import FMDriftKit

@Suite("Suite files")
struct SuiteLoaderTests {
    @Test func readsAMinimalSuite() throws {
        let suite = try SuiteLoader.parse(
            """
            name: capitals
            cases:
              - id: france
                prompt: What is the capital of France?
                expect:
                  - contains: Paris
            """
        )
        #expect(suite.name == "capitals")
        #expect(suite.cases.count == 1)
        let first = try #require(suite.cases.first)
        #expect(first.id == "france")
        #expect(first.prompt == "What is the capital of France?")
        #expect(first.assertions == [Assertion(.contains(["Paris"]))])
        #expect(first.repeatCount == 1)
        #expect(first.minPassRate == 1)
        #expect(first.settings == GenerationSettings())
    }

    @Test func casesInheritDefaultsAndOverrideThem() throws {
        let suite = try SuiteLoader.parse(
            """
            defaults:
              instructions: Answer briefly.
              repeat: 5
              minPassRate: 80%
              sampling: { mode: random, top: 40, seed: 7 }
              temperature: 0.5
              maxResponseTokens: 120
              guardrails: permissive
              useCase: contentTagging
            cases:
              - id: inherits
                prompt: One
                expect: [{ maxLength: 10 }]
              - id: overrides
                prompt: Two
                repeat: 2
                minPassRate: 0.5
                sampling: greedy
                instructions: ""
                expect: [{ maxLength: 10 }]
            """
        )
        let inherits = suite.cases[0]
        #expect(inherits.repeatCount == 5)
        #expect(inherits.minPassRate == 0.8)
        #expect(inherits.settings.instructions == "Answer briefly.")
        #expect(inherits.settings.sampling == .randomTop(40, seed: 7))
        #expect(inherits.settings.temperature == 0.5)
        #expect(inherits.settings.maximumResponseTokens == 120)
        #expect(inherits.settings.guardrails == .permissiveContentTransformations)
        #expect(inherits.settings.useCase == .contentTagging)

        let overrides = suite.cases[1]
        #expect(overrides.repeatCount == 2)
        #expect(overrides.minPassRate == 0.5)
        #expect(overrides.settings.sampling == .greedy)
        #expect(overrides.settings.instructions == nil)
        #expect(overrides.settings.temperature == 0.5)
    }

    @Test(arguments: [
        ("greedy", Sampling.greedy),
        ("random", Sampling.random),
        ("{ mode: random }", Sampling.random),
        ("{ mode: random, top: 10, seed: 3 }", Sampling.randomTop(10, seed: 3)),
        ("{ mode: random, probabilityThreshold: 0.9 }", Sampling.randomProbability(0.9, seed: nil)),
        ("{ mode: greedy }", Sampling.greedy),
    ])
    func readsSamplingModes(text: String, expected: Sampling) throws {
        let suite = try SuiteLoader.parse(
            "cases:\n  - id: a\n    prompt: p\n    sampling: \(text)\n    expect: [{ maxLength: 1 }]"
        )
        #expect(suite.cases[0].settings.sampling == expected)
    }

    @Test func readsEveryAssertionKind() throws {
        let suite = try SuiteLoader.parse(
            """
            cases:
              - id: all
                prompt: p
                schema:
                  type: object
                  properties:
                    title: { type: string }
                    count: { type: integer }
                expect:
                  - contains: [a, b]
                  - containsAny: [c, d]
                  - notContains: e
                  - equals: 42
                    path: count
                  - equals: "42"
                  - oneOf: [x, "y", 3, true]
                    ignoreCase: true
                  - matches: '^\\w+$'
                  - notMatches: 'sorry'
                  - minLength: 1
                    path: title
                  - maxLength: 80
                  - atLeast: 1
                    path: count
                  - atMost: 9.5
                    path: count
                  - maxLatency: 800ms
                  - maxLatency: 2.5s
                  - maxLatency: 3
                  - maxOutputTokens: 200
                  - refusal: false
            """
        )
        let kinds = suite.cases[0].assertions.map(\.kind)
        #expect(
            kinds == [
                .contains(["a", "b"]),
                .containsAny(["c", "d"]),
                .notContains(["e"]),
                .equals(.number(42)),
                .equals(.string("42")),
                .oneOf([.string("x"), .string("y"), .number(3), .bool(true)]),
                .matches(#"^\w+$"#),
                .notMatches("sorry"),
                .minLength(1),
                .maxLength(80),
                .atLeast(1),
                .atMost(9.5),
                .maxLatency(0.8),
                .maxLatency(2.5),
                .maxLatency(3),
                .maxOutputTokens(200),
                .refusal(false),
            ]
        )
        #expect(suite.cases[0].assertions[3].path == ["count"])
        #expect(suite.cases[0].assertions[5].ignoreCase)
    }

    @Test func nameDefaultsToTheFileName() throws {
        let suite = try SuiteLoader.parse(
            "cases: [{ id: a, prompt: p, expect: [{ maxLength: 1 }] }]",
            defaultName: "my suite/../x"
        )
        #expect(suite.name == "my-suite-..-x")
    }

    @Test func readsJSONSuites() throws {
        let suite = try SuiteLoader.parse(
            #"{"name": "json", "cases": [{"id": "a", "prompt": "p", "expect": [{"contains": "x"}]}]}"#
        )
        #expect(suite.name == "json")
        #expect(suite.cases[0].assertions == [Assertion(.contains(["x"]))])
    }

    @Test func loadsFromAFile() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("greetings.yaml")
        try "cases: [{ id: a, prompt: p, expect: [{ maxLength: 1 }] }]".write(
            to: url, atomically: true, encoding: .utf8)
        #expect(try SuiteLoader.load(contentsOf: url).name == "greetings")

        let missing = directory.appendingPathComponent("missing.yaml")
        #expect(throws: SuiteError.self) { try SuiteLoader.load(contentsOf: missing) }
    }
}

@Suite("Suite file errors")
struct SuiteLoaderErrorTests {
    private func message(_ text: String) -> String {
        do {
            _ = try SuiteLoader.parse(text, file: "suite.yaml")
            return "no error"
        } catch {
            return error.description
        }
    }

    @Test func suggestsTheKeyThatWasMeant() {
        let text = "cases:\n  - id: a\n    prompt: p\n    expect:\n      - contans: Paris\n"
        #expect(message(text) == "suite.yaml:5: case `a` check: unknown key `contans`; did you mean `contains`?")
    }

    @Test func listsKeysWhenNothingIsClose() {
        #expect(
            message("colour: blue\ncases: []")
                == "suite.yaml:1: the suite: unknown key `colour`; expected one of cases, defaults, name"
        )
    }

    @Test(arguments: [
        ("", "suite.yaml: is empty; a suite needs `cases`"),
        ("name: x", "suite.yaml:1: needs a `cases` list"),
        ("cases: []", "suite.yaml:1: `cases` must be a non-empty list"),
        ("cases: [{ prompt: p }]", "suite.yaml:1: case 1 needs an `id`"),
        ("cases: [{ id: a }]", "suite.yaml:1: case `a` needs a `prompt`"),
        ("cases: [{ id: a, prompt: '  ' }]", "suite.yaml:1: case `a`: `prompt` is empty"),
        ("cases: [{ id: a, prompt: p }]", "suite.yaml:1: case `a` has nothing to check; add `expect` or a `schema`"),
        (
            "cases: [{ id: 'a b', prompt: p }]",
            "suite.yaml:1: `id` must be 1–64 letters, digits, `-`, `_` or `.`, not starting with `.`"
        ),
        (
            "cases: [{ id: a, prompt: p, repeat: 0, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: `repeat` must be between 1 and 100"
        ),
        (
            "cases: [{ id: a, prompt: p, repeat: '3', expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: `repeat` must be a whole number"
        ),
        (
            "cases: [{ id: a, prompt: p, minPassRate: 120%, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: `minPassRate` must be a share between 0 and 1, or a percentage such as 80%"
        ),
        (
            "cases: [{ id: a, prompt: p, temperature: 3, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: `temperature` must be between 0 and 2"
        ),
        (
            "cases: [{ id: a, prompt: p, guardrails: off, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: `guardrails` is `off`; use `default` or `permissiveContentTransformations`"
        ),
        (
            "cases: [{ id: a, prompt: p, useCase: chat, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: `useCase` is `chat`; use `general` or `contentTagging`"
        ),
        (
            "cases: [{ id: a, prompt: p, sampling: hot, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: `sampling` is `hot`; use `greedy`, `random` or a mapping"
        ),
        (
            "cases: [{ id: a, prompt: p, sampling: { mode: random, top: 5, probabilityThreshold: 0.5 }, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: use either `top` or `probabilityThreshold`, not both"
        ),
        (
            "cases: [{ id: a, prompt: p, sampling: { mode: greedy, seed: 1 }, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: greedy sampling takes no `top`, `probabilityThreshold` or `seed`"
        ),
        (
            "cases: [{ id: a, prompt: p, sampling: { mode: random, seed: 1 }, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: a `seed` needs `top` or `probabilityThreshold`; the framework takes a seed only with one of them"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{}] }]",
            "suite.yaml:1: case `a`: each check needs exactly one of atLeast, atMost, contains, containsAny, equals, matches, maxLatency, maxLength, maxOutputTokens, minLength, notContains, notMatches, oneOf, refusal (found none)"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{ contains: a, maxLength: 3 }] }]",
            "suite.yaml:1: case `a`: each check needs exactly one of atLeast, atMost, contains, containsAny, equals, matches, maxLatency, maxLength, maxOutputTokens, minLength, notContains, notMatches, oneOf, refusal (found contains, maxLength)"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{ contains: a, path: x }] }]",
            "suite.yaml:1: case `a`: `path` reads structured output; add a `schema` to the case"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{ maxLatency: 1s, path: x }] }]",
            "suite.yaml:1: case `a`: `maxLatency` applies to the whole response and takes no `path`"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{ maxLength: 3, ignoreCase: true }] }]",
            "suite.yaml:1: case `a`: `ignoreCase` only applies to contains, containsAny, equals, notContains, oneOf"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{ matches: '(' }] }]",
            "suite.yaml:1: `matches` is not a valid regular expression: ("
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{ maxLatency: soon }] }]",
            "suite.yaml:1: `maxLatency` must be a duration such as 2s, 1.5s or 800ms"
        ),
        ("cases: [{ id: a, prompt: p, expect: [{ refusal: yes }] }]", "suite.yaml:1: `refusal` must be true or false"),
        (
            "cases: [{ id: a, prompt: p, expect: [{ contains: [] }] }]",
            "suite.yaml:1: `contains` must not be an empty list"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: { contains: x } }]",
            "suite.yaml:1: case `a`: `expect` must be a list of checks"
        ),
        (
            "cases: [{ id: a, prompt: p, expect: [{ maxLength: 1 }] }, { id: a, prompt: q, expect: [{ maxLength: 1 }] }]",
            "suite.yaml:1: case id `a` is already used by case 1"
        ),
    ])
    func explainsWhatIsWrong(text: String, expected: String) {
        #expect(message(text) == expected)
    }

    @Test func reportsTheLineOfAYAMLSyntaxError() {
        let text = "cases:\n  - id: a\n    prompt: [unclosed\n"
        #expect(message(text).hasPrefix("suite.yaml:4: is not valid YAML"))
    }

    @Test func rejectsDuplicateKeys() {
        let text = "cases:\n  - id: a\n    id: b\n    prompt: p\n"
        #expect(message(text).contains("duplicate keys id"))
    }

    @Test func stopsAliasExpansionWithANodeBudget() {
        var lines = ["a0: &a0 [x, x, x, x, x, x, x, x, x, x]"]
        for level in 1...8 {
            let previous = "*a\(level - 1)"
            lines.append("a\(level): &a\(level) [\(Array(repeating: previous, count: 10).joined(separator: ", "))]")
        }
        lines.append("cases: [{ id: a, prompt: p, expect: [{ equals: *a8 }] }]")
        #expect(message(lines.joined(separator: "\n")).contains("unknown key `a0`"))

        // The same expansion inside an allowed value hits the node budget instead.
        let nested = """
            defaults:
              instructions: x
            cases:
              - id: a
                prompt: p
                expect:
                  - equals: &a0 [x, x, x, x, x, x, x, x, x, x]
                  - equals: &a1 [*a0, *a0, *a0, *a0, *a0, *a0, *a0, *a0, *a0, *a0]
                  - equals: &a2 [*a1, *a1, *a1, *a1, *a1, *a1, *a1, *a1, *a1, *a1]
                  - equals: &a3 [*a2, *a2, *a2, *a2, *a2, *a2, *a2, *a2, *a2, *a2]
                  - equals: &a4 [*a3, *a3, *a3, *a3, *a3, *a3, *a3, *a3, *a3, *a3]
                  - equals: &a5 [*a4, *a4, *a4, *a4, *a4, *a4, *a4, *a4, *a4, *a4]
                  - equals: &a6 [*a5, *a5, *a5, *a5, *a5, *a5, *a5, *a5, *a5, *a5]
            """
        #expect(message(nested).contains("has more than 200000 YAML nodes"))
    }

    @Test func refusesOversizedText() {
        let text = String(repeating: "#", count: SuiteLoader.maximumFileSize + 1)
        #expect(message(text) == "suite.yaml: is larger than 1048576 bytes")
    }
}
