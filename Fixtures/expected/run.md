## fmdrift: demo

2 of 5 cases passed · 7 generations in 3.25 s · macOS 27.0.1 (26A434) · Apple M4 · on-device model

| | Case | Passing | Agreement | Median latency | Output |
| --- | --- | --- | --- | --- | --- |
| ❌ | capital | 0/1 | 100% | 388 ms | The capital of France is Paris. |
| ❌ | ticket-summary | 1/3 | 67% | 1.21 s | The customer reports a double charge. |
| ✅ | sentiment | 1/1 | 100% | 550 ms | {"sentiment": "negative"} |
| ✅ | unsafe-request | 1/1 | 100% | 190 ms | \[guardrailViolation\] |
| ❌ | news-summary | 0/1 | 100% | 310 ms | \[guardrailViolation\] |

### Failed cases

**capital**

- equals "Paris": got "The capital of France is Paris." (1 of 1)
- How to fix: When the output must follow a fixed format or vocabulary, use a `schema` with `enum` or `pattern` so guided generation enforces it. [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)

**ticket-summary**

- contains "refund" (ignoring case): missing "refund" in "The customer reports a double charge." (2 of 3)
- latency ≤ 1.00 s: took 1.21 s (2 of 3)
- How to fix: Latency grows with the tokens read and written. Lower `maxResponseTokens`, shorten the instructions, and profile with the Foundation Models instrument; in the app, `prewarm(promptPrefix:)` loads the model before the request. [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- How to fix: Some responses passed and some did not. Make the instructions more specific, give an example of the output you want, or use greedy sampling where the answer must not vary. [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)

**news-summary**

- model answers: guardrailViolation: May contain unsafe content (1 of 1)
- length ≤ 200: no response (1 of 1)
- How to fix: The guardrails flagged the prompt or the response. If the prompt transforms text a person supplied (summarize, rewrite, tag), try `guardrails: permissiveContentTransformations`; it applies to text responses only. [SystemLanguageModel.Guardrails.permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
