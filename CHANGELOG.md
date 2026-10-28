# Changelog

All notable changes to fmdrift are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Until 1.0, a minor version may change
the suite or snapshot format; the notes say how to move.

## [Unreleased]

### Added

- Suites in YAML or JSON: prompt, instructions, sampling, temperature, response token limit,
  guardrails, use case, repeats and a required pass rate per case, with defaults. Unknown keys are
  errors with a "did you mean" hint.
- Checks: `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`,
  `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens` and `refusal`,
  with `path` into structured answers and `ignoreCase`.
- Guided generation from a JSON Schema subset (object, string with enum or pattern, integer and
  number bounds, boolean, array with item counts), and validation of the answer against it.
- `fmdrift run` on the on-device model, with agreement between repeats, and `--baseline` to
  compare with the newest snapshot of another OS build.
- `fmdrift record`: one snapshot per suite and OS build; `fmdrift diff` of two snapshots with
  regressed, fixed, still failing, changed, unchanged, added and removed cases, newly failing
  checks, a word diff of the answers and an optional latency limit; `--fail-on` policies.
- `fmdrift run --replay`: check the answers in a snapshot without a model.
- `fmdrift validate`, `fmdrift init` and `fmdrift doctor`.
- Terminal, Markdown, JUnit XML and JSON reports; exit codes 0, 1 and 2; `--allow-unavailable`
  for runners without Apple Intelligence.
- Suggestions for failed and regressed cases, each linked to Apple's documentation.
- FMDriftKit library with DocC documentation, a support-inbox example recorded on macOS 27.0.1
  (26A434), a Swift library example and a GitHub Actions example.
