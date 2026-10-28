# Security policy

## Supported versions

Security fixes are made for the latest release of each project. If you are on an older version,
the fix will be in a new release and the upgrade notes will say if anything changes for you.

## Reporting a vulnerability

Please report vulnerabilities privately, not in a public issue, pull request or discussion.

1. **Preferred:** open the repository's **Security** tab and choose
   **Report a vulnerability** ([how private reporting works](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)).
2. **Or** email [muhittincamdali@gmail.com](mailto:muhittincamdali@gmail.com) with
   "Security" in the subject.

Include what you can of the following:

- the affected repository and version (tag or commit),
- what an attacker can do and under which conditions,
- steps or a small file that reproduces it,
- any fix or mitigation you already have in mind.

## What happens next

- You get a reply within 7 days confirming that the report arrived.
- I confirm the issue, work on a fix and agree a disclosure date with you. Fixes are released as
  soon as they are ready, together with a GitHub security advisory.
- You are credited in the advisory unless you prefer not to be.

Please give a reasonable amount of time to fix the issue before disclosing it publicly.

## Scope for fmdrift

fmdrift reads suite files and snapshot files, sends the prompts of a suite to the on-device model
through Apple's Foundation Models framework, and writes only what you ask for: snapshots with
`record` (under `--dir`, named after the suite and the OS build), report files with `--junit` and
`--markdown`, and `fmdrift.yaml` with `init` (an existing file only with `--force`). It makes no
network requests of its own and runs no code from a suite or snapshot.

Model answers, suites and snapshots are treated as untrusted input. Reports that fit this policy
include, for example:

- an answer, case id, suite name or file name that makes the terminal, Markdown or JUnit report
  run escape sequences, render markup, reorder text through bidirectional controls, or hide
  text with invisible characters,
- a suite or snapshot file that crashes fmdrift, exhausts memory or the stack, or keeps it busy
  far beyond its size, despite the limits (1 MiB and 200,000 YAML nodes per suite, 32 MiB and 64
  levels of nesting per snapshot),
- a suite or snapshot name that makes `record` write outside the snapshot folder.

What the model says, and whether Apple's guardrails flag it, is outside fmdrift's control; report
model behaviour to Apple through Feedback Assistant.
