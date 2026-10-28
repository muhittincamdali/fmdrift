# Write your first suite

This guide takes a prompt your app already sends to the on-device model and turns it into a
suite that fmdrift can run, record and compare. It takes about ten minutes on a Mac with Apple
Intelligence turned on.

## 1. Check the Mac

```sh
fmdrift doctor
```

`On-device model available` means live runs work. Otherwise doctor says why: the Mac is not
eligible (Apple Intelligence needs Apple silicon), Apple Intelligence is off (System Settings ›
Apple Intelligence & Siri), or the model is still downloading. The `Snapshot name` line is the
file `record` will write on this OS build.

## 2. Copy the prompt from the app

Find the session your feature creates and the call it makes. For example:

```swift
let session = LanguageModelSession(instructions: "You summarize support tickets in one sentence.")
let response = try await session.respond(to: "Summarize: \(ticket.body)")
```

Write it as a case, with a real ticket body in place of the variable:

```yaml
name: support

cases:
    - id: ticket-summary
      instructions: You summarize support tickets in one sentence.
      prompt: 'Summarize: "I was charged twice for the yearly plan this morning. Order 4417."'
      expect:
          - contains: "4417"
```

`id` names the case in reports and snapshots; keep it stable. `instructions` can also go under
`defaults` when several cases share them.

## 3. Say what a good answer is

Turn "a good summary" into checks a machine can make, as Apple's
[evaluation article](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
suggests. For the summary above:

```yaml
expect:
    - containsAny: [charged twice, double charge, duplicate charge]
      ignoreCase: true # the problem is named
    - contains: "4417" # the order number survives
    - notContains: [will refund, has been refunded]
      ignoreCase: true # no promise the app cannot keep
    - maxLength: 240 # fits the inbox row
    - maxLatency: 2s
```

When the app needs fields rather than a sentence, add a `schema`. fmdrift then uses guided
generation, which constrains the model to the shape, and checks values by `path`:

```yaml
- id: ticket-triage
  prompt: 'Triage: "The app crashes every time I open Export."'
  schema:
      type: object
      required: [category, urgency]
      properties:
          category: { type: string, enum: [billing, bug, account, other] }
          urgency: { type: integer, minimum: 1, maximum: 5 }
  expect:
      - path: category
        equals: bug
      - path: urgency
        atLeast: 3
```

## 4. Validate and run

```sh
fmdrift validate
fmdrift run
```

`validate` needs no model; it reports a misspelled key with the one you probably meant
(`unknown key 'contans'; did you mean 'contains'?`). `run` prints one line per case and, for a
failed case, each failing check with what the model said and a suggestion linked to Apple's
documentation.

## 5. Decide how stable it must be

Add `repeat` to run a case several times, each in a new session:

```yaml
defaults:
    repeat: 3
    minPassRate: 100%
```

The report's `agreement` is the share of runs that gave the most common answer. Greedy sampling
(the default) is the right choice for answers that must not vary; with
`sampling: { mode: random, top: 40 }` and a lower `minPassRate` you measure how often a creative
prompt stays within its checks.

## 6. Record

```sh
fmdrift record
git add fmdrift.yaml fmdrift-snapshots
```

The snapshot holds every answer with its latency and token count, under the OS build that
produced it. Next: [catch drift after an OS update](catch-drift-after-an-os-update.md).
