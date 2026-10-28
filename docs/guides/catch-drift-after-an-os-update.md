# Catch drift after an OS update

The on-device model ships with the OS and changes only with an OS update. At WWDC26 Apple said
the model had two updates in the past year, that updates arrive in beta releases, and that the
OS version is the practical signal for which model you have
([Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/),
15:07 and the discussion that follows). Apple's
[Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
asks for the same routine fmdrift automates: record what your prompts produce with the current
model, compare with the new one, and version a prompt only if you have to.

## Before the update: record

On the OS your users have today:

```sh
fmdrift record
git add fmdrift-snapshots && git commit -m "test(prompts): record answers on macOS 26.4"
```

Apple's article calls this record essential, because the older model is only included as part
of the beta program.

## After the update or on a beta: compare

On a Mac with the new OS (a beta seed, or the release):

```sh
fmdrift doctor                                   # confirms the new build
fmdrift run --baseline fmdrift-snapshots
```

With a folder, `--baseline` picks the newest snapshot of the suite from another OS build. Each
case is then:

| Status         | Meaning                                                                          | Fails the run                             |
| -------------- | -------------------------------------------------------------------------------- | ----------------------------------------- |
| regressed      | passed on the old build, fails now                                               | yes                                       |
| changed        | still passes, but the most common answer, the pass rate or the agreement differs | with `--fail-on changed`                  |
| fixed          | failed before, passes now                                                        | no                                        |
| still failing  | failed on both                                                                   | no (the run fails because the case fails) |
| added, removed | only in one of the runs                                                          | with `--fail-on changed`                  |

`--max-latency-increase 50%` also fails on cases whose median latency grew by more than half.
Compare latency only between snapshots from the same Mac.

The output line shows a word diff of the answers: `[-removed-]` and `{+added+}`.

## Read the difference

- **Regressed with the same prompt**: the new model answers differently. Read the answers, then
  rephrase the prompt so it works on both models if you can; Apple's advice in the lab was to
  avoid OS-specific prompt wording where possible.
- **The note "the prompt, instructions, options or schema changed between the runs"**: the
  difference may come from your edit, not the model. Record again on the old OS, or compare with
  a snapshot of the same prompt.
- **A text refusal became `guardrailViolation`** (or the reverse): the answer is the same in
  spirit, but the app now takes a different code path (an error instead of a string). On macOS
  27.0.1 a shorter instruction alone was enough to make that change in the
  [support example](../../Examples/README.md#support-app).

## Keep a prompt per OS release only when needed

If one wording cannot serve both models, keep both and choose at run time, as Apple's article
shows:

```swift
if #available(iOS 27.0, macOS 27.0, *) {
    instructions = String(localized: "support-ticket-summarizer-v1.1", table: "Prompts")
} else {
    instructions = String(localized: "support-ticket-summarizer-v1.0", table: "Prompts")
}
```

Give each version its own case (`ticket-summary-v1-0`, `ticket-summary-v1-1`) so the suite keeps
checking both.

## Commit the new snapshot

Once the new OS answers well:

```sh
fmdrift record
git add fmdrift-snapshots && git commit -m "test(prompts): record answers on macOS 27.0.1"
```

Both snapshots stay in the folder; `fmdrift diff` compares any two of them later.
