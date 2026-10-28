# Examples

| Folder | What it shows |
| --- | --- |
| [support-app](support-app) | A five-case suite from a photo-editing app's support inbox, with a snapshot recorded on macOS 27.0.1 (26A434), Apple M5 Max |
| [LibraryUsage](LibraryUsage) | PromptGate: FMDriftKit from Swift code, with its own pass rule |
| [github-actions](github-actions) | A workflow that validates suites and re-checks recorded answers on hosted runners, and runs the model on a self-hosted Mac |

## support-app

```sh
cd Examples/support-app
fmdrift validate                                 # no model needed
fmdrift run --replay fmdrift-snapshots           # checks the recorded answers, no model needed
fmdrift run                                      # asks the on-device model again
fmdrift run --baseline fmdrift-snapshots         # and compares with the recording
```

The suite covers a summary that must not promise a refund, triage with guided generation (an
enum and an integer range), a reply in Spanish under a latency limit, content tagging with the
`contentTagging` use case, and an off-topic request.

The off-topic case checks the words of the answer, not `refusal: true`: in the recording the
model declined with the text "Unable to work with that request." instead of an error. When the
instructions were shortened to "Answer in at most eight words.", the same request threw
`guardrailViolation` on the same OS build, and `run --baseline` reported the case as regressed.

## LibraryUsage

```sh
cd Examples/LibraryUsage
swift run PromptGate ../support-app/fmdrift/support.yaml \
  ../support-app/fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

With a snapshot, PromptGate replays it; without one, it asks the on-device model. It exits with
1 when a case fails or answers differently from the snapshot.

## github-actions

[fmdrift.yml](github-actions/fmdrift.yml) has two jobs. GitHub-hosted macOS runners have no
Apple Intelligence, so the `recorded` job validates the suites and checks the committed answers
again; the `live` job runs on a self-hosted Mac that has the model.

## Flutter and React Native apps

A suite holds the prompt, the instructions and the options, not the app code, so the same file
works for a Flutter or React Native app that calls the on-device model through a plugin. Copy
the prompt and instructions the app sends into a case and keep them in sync with the app.
