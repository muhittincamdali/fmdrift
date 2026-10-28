# Snapshots and diffs

What a snapshot stores, how two are compared, and what each status means.

## Overview

A snapshot is a ``RunResult`` written by ``SnapshotStore`` as JSON with sorted keys and ISO 8601
dates, so that it reads well in a git diff. `fmdrift record` writes one per suite and OS build to
`<directory>/<suite>/<platform>-<version>-<build>.json`, for example
`fmdrift-snapshots/support/macOS-27.0.1-26A434.json`.

## Contents

| Field                                                  | Holds                                                                                                                      |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `format`                                               | The file format version, `1`. A reader refuses a newer format.                                                             |
| `fmdriftVersion`, `recordedAt`, `duration`             | Who wrote it, when, and how long the run took                                                                              |
| `environment`                                          | ``RunEnvironment``: platform, OS version and build, hardware model, chip, locale, provider, model availability, context size |
| `cases[].fingerprint`                                  | SHA-256 of the prompt, instructions, generation options and schema                                                         |
| `cases[].samples[].generation`                         | The answer text (as the model wrote it), latency in seconds, input and output tokens when known, or the failure            |
| `cases[].samples[].checks`                             | Each check with `passed`, `failed` or `skipped` and what was found                                                         |
| `cases[].passCount`, `passRate`, `passed`, `agreement` | Derived from the samples; recomputed when the file is read                                                                 |

Files larger than 32 MiB or nested deeper than 64 levels are refused before decoding.

## Statuses

``SnapshotDiff`` matches cases by `id` and gives each one a status:

| Status         | Baseline | Current                                                                    |
| -------------- | -------- | -------------------------------------------------------------------------- |
| `regressed`    | passed   | fails                                                                      |
| `fixed`        | failed   | passes                                                                     |
| `stillFailing` | failed   | fails                                                                      |
| `changed`      | passed   | passes, but the most common answer, the pass rate or the agreement differs |
| `unchanged`    | passed   | passes the same way                                                        |
| `added`        | missing  | present                                                                    |
| `removed`      | present  | missing                                                                    |

`inputChanged` is set when the fingerprints differ, so an edited prompt is not mistaken for a
new model. `newlyFailingChecks` lists checks that fail now and passed in every baseline answer.
With a latency share, `slower` marks a case whose median latency grew by more than it.

## Failure policies

``SnapshotDiff/FailurePolicy`` decides what fails a comparison:

- `regressed` (default): a regressed case, or a slower one when a latency share is set.
- `changed`: also changed, added and removed cases.
- `never`: report only.
