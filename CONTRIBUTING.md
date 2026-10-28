# Contributing to fmdrift

Thanks for taking the time to improve fmdrift. The
[shared contributing guide](https://github.com/muhittincamdali/.github/blob/main/CONTRIBUTING.md)
applies (small fixes as a pull request, larger changes as an issue first, security issues through
[SECURITY.md](SECURITY.md), the
[code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) for
everyone). This file adds what is specific to this repository.

## Set up

macOS 26 or later with Xcode 26.4 or later (Swift 6.2 or later).

```sh
git clone https://github.com/muhittincamdali/fmdrift.git
cd fmdrift
swift build
swift test
```

The tests need neither the network nor the on-device model: a scripted provider stands in for
the model, and the support-app snapshot recorded on a real Mac is replayed. CI runs them with
Xcode 26.6 (`ci.yml`, `examples.yml`) and Xcode 27 (`examples.yml`, on the `xcode-27` preview
image), and lints with `lint.yml`.

| Command | What it does |
| --- | --- |
| `swift test` | Unit, report, command-line and recorded-snapshot tests |
| `FMDRIFT_LIVE=1 swift test --filter Live` | Two tests on the real on-device model (a Mac with Apple Intelligence) |
| `FMDRIFT_RECORD_EXPECTED=1 swift test --filter Report` | Rewrites `Fixtures/expected/` after an intended report change |
| `swift format lint --strict -r Sources Tests Package.swift` | The lint check CI runs |
| `swift build -c release && node scripts/demo.mjs` | Records the terminal demos in `docs/media/` (needs the model and Node.js 22 or later) |
| `cd Examples/support-app && ../../.build/release/fmdrift record` | Records the example snapshot again (needs the model) |

## Where things live

- `Sources/FMDriftKit/`: `Suite`, `SuiteLoader` and `JSONSchema` read suites; `Evaluator` and
  `SchemaValidator` check answers; `Runner`, `ModelProvider`, `SystemModelProvider` and
  `ReplayProvider` run them; `RunResult`, `SnapshotStore`, `SnapshotDiff` and `WordDiff` keep and
  compare results; `Advice` holds the suggestions and their Apple sources; `Reports/` renders them.
- `Sources/FMDriftCLI/`: the commands and exit codes; `Sources/fmdrift/` only starts them.
- `Fixtures/expected/`: the report formats the tests compare with.
- `Examples/`: the support-app suite and snapshot, the PromptGate library example, a GitHub
  Actions workflow.

## Tests

- A bug fix starts with a test that fails without it. A wrong verdict is best reported with the
  suite and the snapshot that produced it; `fmdrift run --replay` reproduces it without a model.
- When a report changes on purpose, rewrite `Fixtures/expected/`, read the diff, and record the
  demos again if the terminal output changed.
- Do not edit a recorded snapshot by hand. Record it again on a Mac with the model and say in the
  commit which OS build and Mac it came from.

## Wording

fmdrift reports what it observed. Give every figure in the README with the OS build and Mac it was
measured on, link each suggestion to the Apple page it rests on, and keep planned features marked
as planned. The hygiene check in CI flags unverifiable wording.
