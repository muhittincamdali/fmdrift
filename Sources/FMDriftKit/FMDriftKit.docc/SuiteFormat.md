# Suite format

Every key of a suite file, its values and its limits.

## Overview

A suite is a YAML file (JSON works too, since JSON is YAML). ``SuiteLoader`` reads it and
refuses unknown keys with the closest known key as a hint, because a misspelled check would
otherwise pass without checking anything.

```yaml
name: support # optional; defaults to the file name
defaults: # optional; applies to every case
    repeat: 3
    minPassRate: 100%
    instructions: You help the support team of a photo-editing app.
cases:
    - id: ticket-summary
      prompt: 'Summarize: "I was charged twice. Order 4417."'
      expect:
          - contains: "4417"
```

## Top level

| Key        | Value                                                                                           |
| ---------- | ----------------------------------------------------------------------------------------------- |
| `name`     | 1 to 64 letters, digits, `-`, `_` or `.`, not starting with `.`. Snapshots are stored under it. |
| `defaults` | Any case setting from the next table; a case overrides it.                                      |
| `cases`    | A list of 1 to 500 cases.                                                                       |

## Case settings

These keys may appear in `defaults` and in each case.

| Key                 | Value                                                                                                                                                                            | Maps to                                   |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| `instructions`      | Text; empty means none                                                                                                                                                           | `LanguageModelSession(instructions:)`     |
| `sampling`          | `greedy` (default), `random`, or `{ mode: random, top: 40, seed: 7 }` or `{ mode: random, probabilityThreshold: 0.9, seed: 7 }`. A `seed` needs `top` or `probabilityThreshold`. | `GenerationOptions.SamplingMode`          |
| `temperature`       | 0 to 2                                                                                                                                                                           | `GenerationOptions.temperature`           |
| `maxResponseTokens` | 1 to 100,000                                                                                                                                                                     | `GenerationOptions.maximumResponseTokens` |
| `guardrails`        | `default` or `permissiveContentTransformations` (`permissive` for short)                                                                                                         | `SystemLanguageModel.Guardrails`          |
| `useCase`           | `general` or `contentTagging`                                                                                                                                                    | `SystemLanguageModel.UseCase`             |
| `repeat`            | 1 to 100 runs, each in a new session                                                                                                                                             |                                           |
| `minPassRate`       | Share of runs that must pass: `0.8` or `80%`; default 1                                                                                                                          |                                           |

## Case keys

| Key      | Value                                                                                            |
| -------- | ------------------------------------------------------------------------------------------------ |
| `id`     | Required. Unique in the suite; same characters as `name`.                                        |
| `prompt` | Required. At most 100,000 characters.                                                            |
| `schema` | A JSON Schema; see below. The answer is generated with guided generation and checked against it. |
| `expect` | A list of checks. A case needs `expect`, a `schema`, or both.                                    |

## Checks

Each entry of `expect` has exactly one check. `path` and `ignoreCase` modify it.

| Check                           | Passes when                                                                              |
| ------------------------------- | ---------------------------------------------------------------------------------------- |
| `contains: text` or `[a, b]`    | every string appears                                                                     |
| `containsAny: [a, b]`           | at least one appears                                                                     |
| `notContains: text` or `[a, b]` | none appears                                                                             |
| `equals: value`                 | the answer, trimmed, equals the value; with `path`, the JSON value at the path equals it |
| `oneOf: [a, b]`                 | as `equals`, for any of the values                                                       |
| `matches: regex`                | the regular expression matches somewhere; fails if matching takes over 2 s               |
| `notMatches: regex`             | it matches nowhere; fails if matching takes over 2 s                                     |
| `minLength: n`, `maxLength: n`  | characters of the text; items when `path` points at an array                             |
| `atLeast: n`, `atMost: n`       | the number (at `path`, or the whole answer) is within the bound                          |
| `maxLatency: 2s`                | the answer arrived in time: `800ms`, `1.5s`, or a number of seconds; at most `3600s`     |
| `maxOutputTokens: n`            | the answer has at most n tokens; skipped when the OS cannot count them                   |
| `refusal: true`                 | the model declined with a `guardrailViolation` or `refusal` error                        |
| `refusal: false`                | the model answered                                                                       |

| Modifier              | Effect                                                                                                                                   |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `path: items.0.title` | Read the value at this dot path of a structured answer. Needs a `schema`. Not allowed with `maxLatency`, `maxOutputTokens` or `refusal`. |
| `ignoreCase: true`    | Compare without regard to case. For `contains`, `containsAny`, `notContains`, `equals`, `oneOf`.                                         |

When the model fails with an error and the case has no `refusal` check, a `model answers`
check fails and names the error. A decline written as text ("Sorry, I can't help with that") is an
answer, not an error; check its words with `containsAny`.

## Schemas

Only the JSON Schema keywords that guided generation can express are accepted:

| Type      | Keywords                                                                     |
| --------- | ---------------------------------------------------------------------------- |
| `object`  | `properties` (at least one), `required`, `description`, `title`              |
| `string`  | `enum` (strings) or `pattern` (a regular expression), `description`, `title` |
| `integer` | `minimum`, `maximum` (whole numbers), `description`, `title`                 |
| `number`  | `minimum`, `maximum`, `description`, `title`                                 |
| `boolean` | `description`, `title`                                                       |
| `array`   | `items` (required), `minItems`, `maxItems`, `description`, `title`           |

Schemas nest at most 16 levels. A property not listed in `required` is optional. `description`
is passed to the model as a hint.

Structured answers are compared by value: two answers with the same values in a different key
order count as the same answer for agreement and diffs.

## Limits

A suite file is at most 1 MiB with at most 500 cases. YAML anchors and aliases are allowed, but
reading stops after 200,000 YAML nodes, which keeps an alias that expands exponentially from
stalling the reader.
