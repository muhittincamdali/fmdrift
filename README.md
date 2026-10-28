<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-en-light.svg" alt="Guides"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

Apple's on-device foundation model changes with OS updates, and Apple's advice is to test your
prompts on the old and the new model and compare the output ([Updating prompts for new model
versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)).
fmdrift does that from the command line: it runs the prompts in a YAML suite on the model of the
Mac it runs on, checks every answer, records the results per OS build and shows which answers
changed or broke on the next build. Asked at WWDC26 for a runtime model version, Apple answered
that "the practical signal today is the OS version", so that is what fmdrift records
([Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/), 15:07).

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="fmdrift run on the support-app example: five cases, three runs each, all passing, with agreement and median latency per case"></picture>

<sub>Recorded from the real command and the real on-device model (<code>node scripts/demo.mjs</code>)
on <a href="Examples/support-app">Examples/support-app</a>, macOS 27.0.1 (26A434), Mac17,6 (Apple
M5 Max).</sub>

## Highlights

- **Prompts and checks in one file.** A YAML suite holds each prompt with its instructions,
  sampling, guardrails and use case, and the checks its answers must pass: text, regular
  expressions, JSON values, length, latency, output tokens, and whether the model declines.
- **Structured output too.** Give a case a JSON Schema and fmdrift asks for guided generation
  (`DynamicGenerationSchema`), checks the result against the schema and reads values by path.
- **Stability, not one lucky answer.** Each case can run several times in new sessions; the
  report shows how many runs passed and how many gave the same answer.
- **Snapshots per OS build.** `record` saves every answer, latency and token count as JSON under
  the OS build that produced it. `run --baseline` and `diff` show what regressed, changed or got
  fixed, with a word diff of the answers.
- **A fix for each failure, with its source.** Guardrail violations, refusals, context window,
  languages, schema problems, latency and regressions each come with a suggestion linked to
  Apple's documentation.
- **Made for CI.** Terminal, Markdown, JUnit XML and JSON output and exit codes. Runners without
  Apple Intelligence can still validate suites and check recorded answers again.

## Quick start

**1. Install** (macOS 26 or later, with [Homebrew](https://brew.sh)):

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. Write a suite.** `fmdrift init` writes `fmdrift.yaml` with two working cases; replace them
with the prompts your app sends.

```sh
fmdrift init
```

**3. Run it, and record it.** `fmdrift run` checks every answer on this Mac's model. `fmdrift
record` saves the answers for this OS build in `fmdrift-snapshots/`; commit that folder. After the
next OS update, `fmdrift run --baseline fmdrift-snapshots` shows what changed.

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor` says whether this Mac can run the model and which OS build it would record.
[Write your first suite](docs/guides/write-your-first-suite.md) goes through it step by step.

## What works today

| Feature | Status |
| --- | --- |
| YAML or JSON suites with defaults, instructions, sampling, temperature, response token limit, guardrails and use case per case | works |
| Checks: `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`, `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens`, `refusal` | works |
| Guided generation from a JSON Schema subset, schema validation, checks by JSON path | works |
| Repeats with a required pass rate, and agreement between runs | works |
| `record` snapshots per OS build; `run --baseline` and `diff` with regressed, changed, fixed, added and removed cases and latency limits | works |
| `run --replay`: check recorded answers again without a model | works |
| Terminal, Markdown, JUnit XML and JSON output; exit codes 0, 1, 2 | works |
| FMDriftKit library with DocC documentation | works |
| Run a suite on Private Cloud Compute or another `LanguageModel` provider | planned (0.2) |
| Tool-calling cases | planned (0.3) |

## fmdrift and Apple's Evaluations framework

Xcode 27 added Apple's [Evaluations framework](https://developer.apple.com/documentation/evaluations)
(macOS 27 and later): evaluations written in Swift inside a test target, with model judges,
tool-call evaluators and reports in Xcode. Use it when your checks need Swift code or a judge
model. fmdrift is for the other side of the same job:

- the suite is a YAML file that people who do not write Swift can read and edit,
- results are plain JSON files in git, one per OS build, compared from the command line in any
  CI system,
- the package builds for macOS 26, where the Evaluations framework is not available, so the
  answers of the earlier model can be recorded too (live runs in this release were checked on
  macOS 27.0.1 only).

## Installation

| Method | Command |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| Release binary | Download `fmdrift-<version>-macos-arm64.tar.gz` from [Releases](https://github.com/muhittincamdali/fmdrift/releases), check it against `SHA256SUMS`, put `fmdrift` on your `PATH` |
| From source | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release` (the binary is `.build/release/fmdrift`) |
| Swift package | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`, product `FMDriftKit` |

## Usage

### Write cases

```yaml
name: support
defaults:
    repeat: 3 # three new sessions per case; all must pass
    instructions: You help the support team of a photo-editing app.
cases:
    - id: ticket-summary
      prompt: 'Summarize: "I was charged twice for the yearly plan. Order 4417."'
      expect:
          - containsAny: [charged twice, double charge]
            ignoreCase: true
          - contains: "4417"
          - notContains: [will refund]
          - maxLength: 240
          - maxLatency: 2s

    - id: ticket-triage
      prompt: 'Triage: "The app crashes when I open Export."'
      schema: # guided generation; the answer is JSON
          type: object
          required: [category, urgency]
          properties:
              category: { type: string, enum: [billing, bug, account, other] }
              urgency: { type: integer, minimum: 1, maximum: 5 }
      expect:
          - path: category
            equals: bug
```

Every key, with its limits, is in the [suite format reference](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat).
`fmdrift validate` checks a suite without a model and names an unknown key with the one you
probably meant.

### Compare OS builds

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

A case that passed before and fails now is **regressed** and fails the run (exit status 1).
`--fail-on changed` also fails on answers that changed while still passing, and
`--max-latency-increase 50%` on cases that got slower. When the prompt, instructions, options or
schema changed between the two runs, the report says so, so an edited prompt is not mistaken for
a new model.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="fmdrift run --baseline after shortening the instructions: the ticket summary changed wording, and the off-topic request that the model used to decline with text now throws guardrailViolation and is reported as regressed"></picture>

<sub>A real run on macOS 27.0.1 (26A434): the example's instructions were shortened to "Answer in
at most eight words." and compared with the committed snapshot. The off-topic request that the
model had declined with the text "Unable to work with that request." now threw
<code>guardrailViolation</code>. Only one OS build was available for this release, so this demo
changes the prompt instead of the OS; the report is the same.</sub>

### Check recorded answers without a model

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay runs the checks of the current suite on the answers in a snapshot. It works on any Mac,
including CI runners without Apple Intelligence, and catches a check that no longer matches
what the model said. A case whose prompt changed since the recording is marked.

### Reports for CI

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| Exit status | Meaning |
| --- | --- |
| 0 | Every case passed and nothing regressed |
| 1 | A case failed or regressed (`validate`: a suite is invalid; `doctor`: no model) |
| 2 | Wrong arguments, an unreadable suite or snapshot, or no model to run on |

`--allow-unavailable` turns a missing model into a note and status 0, for runners without Apple
Intelligence. [fmdrift in CI](docs/guides/fmdrift-in-ci.md) has a complete GitHub Actions
workflow.

## How it is tested

- **On the real model.** [Examples/support-app](Examples/support-app) was recorded on macOS
  27.0.1 (26A434), Mac17,6 (Apple M5 Max): 15 generations, all passing, 8.76 s for the whole run,
  medians between 348 ms and 798 ms per answer. A test replays that snapshot through the command
  line on every CI run. Two more tests ask the real model for a plain and a structured answer
  when `FMDRIFT_LIVE=1` is set.
- **What the real model taught the tests.** Ten greedy runs of the triage prompt returned the
  same values in four different key orders, so structured answers are compared by value. The
  off-topic request was declined with text, not an error, as Apple's
  [safety article](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)
  warns, and with shorter instructions the same request threw `guardrailViolation`.
- **Every report format** is compared byte for byte with files in
  [Fixtures/expected](Fixtures/expected), from a fixed baseline and current run that cover each
  kind of outcome.
- **Untrusted text.** Model output can carry terminal escapes, bidirectional overrides or
  markup; the tests feed OSC 52, screen clearing, a right-to-left override, HTML and NUL through
  the terminal, Markdown and JUnit reports. Suite and snapshot readers refuse oversized files,
  deep nesting and YAML alias bombs.
- **Every command in-process**, against a scripted model with a chosen OS build, including
  record on one build, run on another, diff policies, replay, a missing model and unreadable
  files.

84 tests, run by CI on macOS with Xcode 26.6 and Xcode 27.

## Limits

- Live runs need a Mac with Apple silicon and Apple Intelligence turned on. GitHub-hosted macOS
  runners are virtual machines without it; there fmdrift can validate, replay and diff.
- The model on a Mac and on an iPhone with the same OS version may not answer the same way.
  fmdrift runs on macOS only and labels every snapshot with the Mac and OS it came from.
- `refusal: true` passes on a `guardrailViolation` or `refusal` error. A decline written as text
  ("Sorry, I can't help with that") is an ordinary answer: check its words with `containsAny`.
  Apple notes that a text refusal cannot always be told apart from an answer in code.
- Latency includes creating the session; the first answer of a run can be slower while the model
  loads. Compare latency between snapshots from the same Mac.
- Output token counts come from the response on macOS 27 and from `tokenCount(for:)` on macOS
  26.4 to 26.x; before 26.4, `maxOutputTokens` is skipped and says so.
- Apple's [context window article](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
  gives 4,096 tokens; `contextSize` reported 8,192 on macOS 27.0.1 (26A434). `fmdrift doctor`
  prints the value of the Mac at hand.

## Requirements

| Platform | Minimum |
| --- | --- |
| macOS (validate, replay, diff) | 26.0 |
| macOS (live runs) | 26.0 on Apple silicon with Apple Intelligence; checked on 27.0.1 |
| Toolchain (build from source) | Swift 6.2, Xcode 26.4 or later |

## Architecture

- `Sources/FMDriftKit`: `SuiteLoader` reads suites into `Suite` and `TestCase`; `Evaluator` and
  `SchemaValidator` check one `Generation`; `Runner` asks a `ModelProvider`
  (`SystemModelProvider` for the on-device model, `ReplayProvider` for snapshots) and builds a
  `RunResult`; `SnapshotStore` reads and writes it; `SnapshotDiff` compares two; `Advice` maps
  failures to Apple's documentation; `Reports/` renders text, Markdown, JUnit XML and JSON.
- `Sources/FMDriftCLI`: the commands and exit codes; `Sources/fmdrift` only starts them.
- Each generation uses a new `LanguageModelSession`, so no case sees another's transcript.
- Errors are classified by case name because macOS 27 moved them from `GenerationError` to
  `LanguageModelError`; the same binary works on both.

## Documentation

- [Guides](docs/guides/): write your first suite, catch drift after an OS update, fmdrift in CI.
- [API and suite format](https://muhittincamdali.github.io/fmdrift/) (DocC) for FMDriftKit.
- [Examples](Examples/): the support-app suite with its snapshot, a Swift program on FMDriftKit,
  a GitHub Actions workflow.
- [Changelog](CHANGELOG.md).

## Sources

Apple documentation and sessions fmdrift's behaviour and advice rest on, read on 28 October 2026:

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/): the OS version as the model signal (15:07), about two model updates a year, made in beta releases
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) and [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## Contributing

A suite that shows a wrong verdict, with the snapshot that produced it, helps most. See
[CONTRIBUTING.md](CONTRIBUTING.md) for building, tests and recorded files, and
[SECURITY.md](SECURITY.md) for reporting a vulnerability privately.

## License

[MIT](LICENSE)
