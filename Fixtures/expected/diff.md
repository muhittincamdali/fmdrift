## fmdrift diff: demo

| | Environment |
| --- | --- |
| Baseline | macOS 26.4 (25E246) · Apple M4 · recorded 2026-10-20 |
| Current | macOS 27.0.1 (26A434) · Apple M4 · recorded 2026-10-27 |

2 regressed · 0 changed · 0 fixed · 1 added · 2 unchanged

| Status | Case | Passing | Median latency | Note |
| --- | --- | --- | --- | --- |
| ❌ regressed | capital | 100% → 0% | 412 ms → 388 ms (-6%) | newly failing: equals "Paris" |
| ❌ regressed | ticket-summary | 100% → 33% | 820 ms → 1.21 s (+48%) | newly failing: contains "refund" (ignoring case); latency ≤ 1.00 s |
| unchanged | sentiment | 100% → 100% | 600 ms → 550 ms (-8%) |  |
| unchanged | unsafe-request | 100% → 100% | 200 ms → 190 ms (-5%) |  |
| added | news-summary | 0% | – |  |

### Outputs that changed

**capital**

- Baseline: Paris
- Current: The capital of France is Paris.

**ticket-summary**

- Baseline: The customer wants a refund for a double charge.
- Current: The customer reports a double charge.

How to fix capital: The case passed on the baseline OS build and fails on this one. Compare the outputs; if the new model needs other wording, keep a prompt version per OS release and pick it with `if #available`. [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)

How to fix ticket-summary: The case passed on the baseline OS build and fails on this one. Compare the outputs; if the new model needs other wording, keep a prompt version per OS release and pick it with `if #available`. [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
