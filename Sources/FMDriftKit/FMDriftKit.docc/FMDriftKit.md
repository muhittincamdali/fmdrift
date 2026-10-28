# ``FMDriftKit``

Snapshot and regression tests for prompts to Apple's on-device foundation model.

## Overview

FMDriftKit is the library behind the `fmdrift` command. It reads a suite of prompts and checks
from YAML, runs each prompt on a ``ModelProvider``, checks every answer, and records the results
as a ``RunResult`` that can be saved as a snapshot and compared with another one.

```swift
import FMDriftKit

let suite = try SuiteLoader.load(contentsOf: URL(fileURLWithPath: "fmdrift.yaml"))
let result = await Runner(provider: SystemModelProvider()).run(suite)
print(TerminalReport.run(result, style: .plain))

let baseline = try SnapshotStore.read(contentsOf: URL(fileURLWithPath: "fmdrift-snapshots/support/macOS-26.4-25E246.json"))
let diff = SnapshotDiff(baseline: baseline, current: result)
if diff.fails(under: .regressed) { print("A case regressed") }
```

The on-device model changes with OS updates, and there is no runtime model version to read:
the OS version and build identify the model, so ``RunEnvironment`` records them with every run.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:SuiteFormat>
- <doc:SnapshotsAndDiffs>

### Suites

- ``Suite``
- ``TestCase``
- ``GenerationSettings``
- ``Sampling``
- ``Guardrails``
- ``UseCase``
- ``Assertion``
- ``JSONSchema``
- ``SuiteLoader``
- ``SuiteError``

### Running

- ``Runner``
- ``PatternBudget``
- ``ModelProvider``
- ``SystemModelProvider``
- ``ReplayProvider``
- ``GenerationRequest``
- ``Generation``
- ``GenerationFailure``
- ``ModelAvailability``
- ``RunEnvironment``

### Checking

- ``Evaluator``
- ``SchemaValidator``
- ``CheckResult``
- ``Advice``

### Results and snapshots

- ``RunResult``
- ``CaseResult``
- ``SampleResult``
- ``SnapshotStore``
- ``SnapshotError``
- ``SnapshotDiff``
- ``WordDiff``

### Reports

- ``TerminalReport``
- ``TerminalStyle``
- ``MarkdownReport``
- ``JUnitReport``
- ``JSONReport``
- ``TextSafety``
