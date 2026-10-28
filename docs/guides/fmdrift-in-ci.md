# fmdrift in CI

fmdrift has two jobs in CI, and they need different machines.

| Job                                                        | Needs the model | Runs on                                                         |
| ---------------------------------------------------------- | --------------- | --------------------------------------------------------------- |
| `fmdrift validate`, `fmdrift run --replay`, `fmdrift diff` | no              | any Mac with macOS 26 or later, including GitHub-hosted runners |
| `fmdrift run`, `fmdrift record`                            | yes             | a Mac with Apple silicon and Apple Intelligence turned on       |

GitHub-hosted macOS runners are virtual machines; Apple Intelligence is not available there, and
`fmdrift doctor` reports the model as not available.

## On every pull request: validate and replay

```yaml
jobs:
    recorded:
        runs-on: macos-26
        steps:
            - uses: actions/checkout@v5
            - run: brew install muhittincamdali/tap/fmdrift
            - run: fmdrift validate
            - run: fmdrift run --replay fmdrift-snapshots --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
```

`validate` fails (status 1) on a suite with an unknown key or a bad value. `--replay` checks the
current suite against the committed answers: a pull request that tightens a check the recorded
answers do not meet fails here, before anyone runs the model. Cases whose prompt changed since
the recording are marked in the report.

## On a Mac with the model: run and compare

Register a Mac with Apple Intelligence as a
[self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners) with a label
such as `apple-intelligence`:

```yaml
live:
    runs-on: [self-hosted, macOS, apple-intelligence]
    steps:
        - uses: actions/checkout@v5
        - run: fmdrift run --baseline fmdrift-snapshots --markdown "$GITHUB_STEP_SUMMARY"
```

The job fails (status 1) when a case fails or regressed. `--fail-on changed` makes any changed
answer fail too, and `--max-latency-increase 50%` a case that got slower.

If the same workflow can land on a runner without the model, add `--allow-unavailable`: the job
then passes with a note instead of failing with status 2.

## Outputs

| Option                              | Use                                                                           |
| ----------------------------------- | ----------------------------------------------------------------------------- |
| `--markdown "$GITHUB_STEP_SUMMARY"` | The report in the job summary                                                 |
| `--junit fmdrift-junit.xml`         | Test results for CI systems that read JUnit XML; one test case per suite case |
| `--json`                            | Everything, for `jq`: `{ "passed", "runs": [...], "diffs": [...] }`           |

The complete workflow is in [Examples/github-actions/fmdrift.yml](../../Examples/github-actions/fmdrift.yml).

## Record on a schedule

A scheduled job on the self-hosted Mac can record after each OS update and open a pull request
with the new snapshot, so the next comparison has a fresh baseline:

```yaml
on:
    schedule:
        - cron: "0 6 * * 1"
jobs:
    record:
        runs-on: [self-hosted, macOS, apple-intelligence]
        steps:
            - uses: actions/checkout@v5
            - run: fmdrift record
            - run: git status --short fmdrift-snapshots
```

`record` writes a new file only when the OS build is new; on the same build it overwrites that
build's file with the latest answers.
