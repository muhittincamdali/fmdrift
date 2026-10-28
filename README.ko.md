<!-- i18n-source: README.md@ac64b25b73193784abe7b1fbd7738ac6a9609362 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ko-light.svg" alt="가이드"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

Apple의 온디바이스 파운데이션 모델(foundation model)은 OS 업데이트와 함께 바뀌며, Apple은 프롬프트를 이전 모델과 새 모델에서 모두 테스트하고 출력을 비교하라고 권합니다([Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)). fmdrift는 이 일을 명령줄에서 처리합니다. YAML 스위트에 적힌 프롬프트를 실행 중인 Mac의 모델에서 실행하고, 모든 응답을 검사하고, 결과를 OS 빌드별로 기록한 다음, 다음 빌드에서 어떤 응답이 바뀌었거나 깨졌는지 보여 줍니다. WWDC26에서 런타임 모델 버전을 제공해 달라는 질문에 Apple은 "오늘날 실질적인 신호는 OS 버전"이라고 답했고, 그래서 fmdrift는 OS 버전을 기록합니다([Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/), 15:07).

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="support-app 예제에서 실행한 fmdrift run: 케이스 다섯 개를 각각 세 번씩 실행해 모두 통과했으며, 케이스별 일치도와 지연 시간 중앙값이 표시됨"></picture>

<sub>실제 명령과 온디바이스 실제 모델에서 녹화했습니다(<code>node scripts/demo.mjs</code>). 대상은 <a href="Examples/support-app">Examples/support-app</a>이고, 환경은 macOS 27.0.1 (26A434), Mac17,6(Apple M5 Max)입니다.</sub>

## 주요 기능

- **프롬프트와 검사를 파일 하나에.** YAML 스위트에는 각 프롬프트와 그 instructions, 샘플링, guardrail, 사용 사례, 그리고 응답이 통과해야 하는 검사(텍스트, 정규 표현식, JSON 값, 길이, 지연 시간, 출력 토큰 수, 모델이 응답을 거부했는지 여부)가 들어 있습니다.
- **구조화된 출력도 지원합니다.** 케이스에 JSON Schema를 지정하면 fmdrift가 guided generation(`DynamicGenerationSchema`)을 요청하고, 결과를 스키마에 맞게 검사하고, 경로로 값을 읽습니다.
- **운 좋은 응답 한 번이 아니라 안정성을 봅니다.** 각 케이스를 새 세션에서 여러 번 실행할 수 있고, 리포트에는 몇 번이 통과했고 몇 번이 같은 응답을 냈는지 표시됩니다.
- **OS 빌드별 스냅샷.** `record`는 모든 응답, 지연 시간, 토큰 수를 그것을 생성한 OS 빌드 아래에 JSON으로 저장합니다. `run --baseline`과 `diff`는 무엇이 퇴보하고, 바뀌고, 고쳐졌는지를 응답의 단어 단위 diff와 함께 보여 줍니다.
- **실패마다 출처가 있는 해결책.** guardrail 위반, 거부, 컨텍스트 윈도, 언어, 스키마 문제, 지연 시간, 퇴보에는 각각 Apple 문서로 연결되는 제안이 함께 표시됩니다.
- **CI를 위해 만들었습니다.** 터미널, Markdown, JUnit XML, JSON 출력과 종료 코드를 지원합니다. Apple Intelligence가 없는 러너에서도 스위트를 검증하고 기록된 응답을 다시 검사할 수 있습니다.

## 빠른 시작

**1. 설치하세요** (macOS 26 이상, [Homebrew](https://brew.sh) 사용):

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. 스위트를 작성하세요.** `fmdrift init`은 동작하는 케이스 두 개가 들어 있는 `fmdrift.yaml`을 만듭니다. 이를 앱이 보내는 프롬프트로 바꾸세요.

```sh
fmdrift init
```

**3. 실행하고 기록하세요.** `fmdrift run`은 이 Mac의 모델에서 모든 응답을 검사합니다. `fmdrift record`는 이 OS 빌드의 응답을 `fmdrift-snapshots/`에 저장하므로, 이 폴더를 커밋하세요. 다음 OS 업데이트 후에 `fmdrift run --baseline fmdrift-snapshots`를 실행하면 무엇이 바뀌었는지 보여 줍니다.

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor`는 이 Mac에서 모델을 실행할 수 있는지, 그리고 어떤 OS 빌드로 기록되는지 알려 줍니다. [첫 번째 스위트 작성하기](docs/guides/write-your-first-suite.md)에서 단계별로 안내합니다.

## 현재 동작하는 기능

| 기능 | 상태 |
| --- | --- |
| 기본값, 그리고 케이스별 instructions, 샘플링, temperature, 응답 토큰 한도, guardrail, 사용 사례를 지원하는 YAML 또는 JSON 스위트 | 동작 |
| 검사: `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`, `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens`, `refusal` | 동작 |
| JSON Schema 하위 집합을 이용한 guided generation, 스키마 검증, JSON 경로 기반 검사 | 동작 |
| 필요한 통과율을 지정한 반복 실행과 실행 간 일치도 | 동작 |
| OS 빌드별 `record` 스냅샷, 퇴보·변경·수정·추가·삭제된 케이스와 지연 시간 한도를 보여 주는 `run --baseline` 및 `diff` | 동작 |
| `run --replay`: 모델 없이 기록된 응답을 다시 검사 | 동작 |
| 터미널, Markdown, JUnit XML, JSON 출력, 종료 코드 0, 1, 2 | 동작 |
| DocC 문서가 있는 FMDriftKit 라이브러리 | 동작 |
| Private Cloud Compute 또는 다른 `LanguageModel` 공급자에서 스위트 실행 | 계획됨(0.2) |
| 도구 호출(tool-calling) 케이스 | 계획됨(0.3) |

## fmdrift와 Apple의 Evaluations framework

Xcode 27에서 Apple의 [Evaluations framework](https://developer.apple.com/documentation/evaluations)가 추가되었습니다(macOS 27 이상). 테스트 타깃 안에서 Swift로 작성하는 평가이며, 모델 심사, tool-call 평가기, Xcode의 리포트를 갖추고 있습니다. 검사에 Swift 코드나 심사 모델이 필요하다면 그것을 사용하세요. fmdrift는 같은 작업의 다른 쪽을 위한 도구입니다.

- 스위트는 Swift를 쓰지 않는 사람도 읽고 편집할 수 있는 YAML 파일입니다.
- 결과는 git에 저장되는 평범한 JSON 파일(OS 빌드당 하나)이며, 어떤 CI 시스템에서든 명령줄로 비교할 수 있습니다.
- 패키지는 Evaluations framework를 사용할 수 없는 macOS 26용으로도 빌드되므로, 이전 모델의 응답도 기록할 수 있습니다(이번 릴리스의 라이브 실행은 macOS 27.0.1에서만 확인했습니다).

## 설치

| 방법 | 명령 |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| 릴리스 바이너리 | [Releases](https://github.com/muhittincamdali/fmdrift/releases)에서 `fmdrift-<version>-macos-arm64.tar.gz`를 내려받아 `SHA256SUMS`로 확인한 다음, `fmdrift`를 `PATH`에 두세요 |
| 소스에서 | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release` (바이너리는 `.build/release/fmdrift`) |
| Swift 패키지 | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`, 프로덕트 `FMDriftKit` |

## 사용법

### 케이스 작성하기

```yaml
name: support
defaults:
    repeat: 3 # three new sessions per case; all must pass
    instructions: You help the support team of a photo-editing app.
cases:
    - id: ticket-summary
      prompt: 'Summarize: "I was charged twice for the yearly plan. Order 4417."'
      expect:
          - containsAny: [charged twice, double charge]
            ignoreCase: true
          - contains: "4417"
          - notContains: [will refund]
          - maxLength: 240
          - maxLatency: 2s

    - id: ticket-triage
      prompt: 'Triage: "The app crashes when I open Export."'
      schema: # guided generation; the answer is JSON
          type: object
          required: [category, urgency]
          properties:
              category: { type: string, enum: [billing, bug, account, other] }
              urgency: { type: integer, minimum: 1, maximum: 5 }
      expect:
          - path: category
            equals: bug
```

모든 키와 그 제한은 [스위트 형식 레퍼런스](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat)에 있습니다. `fmdrift validate`는 모델 없이 스위트를 검사하고, 알 수 없는 키가 있으면 의도했을 가능성이 높은 키를 함께 알려 줍니다.

### OS 빌드 비교하기

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

이전에는 통과했지만 지금은 실패하는 케이스는 **퇴보**(`regressed`)로 분류되어 실행을 실패시킵니다(종료 상태 1). `--fail-on changed`는 응답이 바뀌었지만 여전히 통과하는 케이스에서도 실패하게 하고, `--max-latency-increase 50%`는 느려진 케이스에서 실패하게 합니다. 두 실행 사이에 프롬프트, instructions, 옵션, 스키마가 바뀌었다면 리포트가 그 사실을 알려 주므로, 수정한 프롬프트를 새 모델로 오해하지 않습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="instructions를 줄인 뒤의 fmdrift run --baseline: 티켓 요약의 표현이 바뀌었고, 모델이 예전에는 텍스트로 거절하던 주제와 무관한 요청이 이제 guardrailViolation을 던져 퇴보로 보고됨"></picture>

<sub>macOS 27.0.1 (26A434)에서의 실제 실행입니다. 예제의 instructions를 "Answer in at most eight words."로 줄여 커밋된 스냅샷과 비교했습니다. 모델이 "Unable to work with that request." 텍스트로 거절하던 주제와 무관한 요청이 이제 <code>guardrailViolation</code>을 던졌습니다. 이번 릴리스에서는 OS 빌드를 하나만 쓸 수 있었기 때문에, 이 데모는 OS가 아니라 프롬프트를 바꿉니다. 리포트는 같습니다.</sub>

### 모델 없이 기록된 응답 검사하기

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay는 현재 스위트의 검사를 스냅샷에 있는 응답에 적용합니다. Apple Intelligence가 없는 CI 러너를 포함해 어떤 Mac에서도 동작하며, 모델이 실제로 말한 내용과 더 이상 맞지 않는 검사를 찾아냅니다. 녹화 이후 프롬프트가 바뀐 케이스에는 표시가 붙습니다.

### CI용 리포트

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| 종료 상태 | 의미 |
| --- | --- |
| 0 | 모든 케이스가 통과했고 퇴보가 없음 |
| 1 | 케이스가 실패했거나 퇴보함(`validate`: 스위트가 올바르지 않음, `doctor`: 모델 없음) |
| 2 | 인수가 잘못되었거나, 스위트 또는 스냅샷을 읽을 수 없거나, 실행할 모델이 없음 |

`--allow-unavailable`은 모델이 없는 상황을 메모로 바꾸고 상태 0을 반환하며, Apple Intelligence가 없는 러너를 위한 옵션입니다. [CI에서 fmdrift 사용하기](docs/guides/fmdrift-in-ci.md)에 완전한 GitHub Actions 워크플로가 있습니다.

## 테스트 방법

- **실제 모델에서.** [Examples/support-app](Examples/support-app)은 macOS 27.0.1 (26A434), Mac17,6(Apple M5 Max)에서 기록했습니다. 생성 15회가 모두 통과했고, 전체 실행에 9.70 s가 걸렸으며, 응답당 중앙값은 374 ms에서 826 ms 사이였습니다. 테스트 하나가 CI를 실행할 때마다 이 스냅샷을 명령줄로 재생합니다. `FMDRIFT_LIVE=1`을 설정하면 테스트 두 개가 더 실제 모델에 일반 응답과 구조화된 응답을 요청합니다.
- **실제 모델이 테스트에 가르쳐 준 것.** 분류(triage) 프롬프트를 greedy로 열 번 실행하자 같은 값이 서로 다른 키 순서 네 가지로 반환되었으므로, 구조화된 응답은 값으로 비교합니다. 주제와 무관한 요청은 Apple의 [안전 관련 문서](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)가 경고한 대로 오류가 아니라 텍스트로 거절되었고, instructions를 줄이자 같은 요청이 `guardrailViolation`을 던졌습니다.
- **모든 리포트 형식**은 [Fixtures/expected](Fixtures/expected)의 파일과 바이트 단위로 비교합니다. 이 파일은 모든 종류의 결과를 포함하는 고정된 baseline과 현재 실행에서 만들어집니다.
- **신뢰할 수 없는 텍스트.** 모델 출력에는 터미널 이스케이프, 양방향 텍스트 덮어쓰기, 마크업이 들어 있을 수 있습니다. 테스트는 OSC 52, 화면 지우기, 오른쪽에서 왼쪽으로의 덮어쓰기, HTML, NUL을 터미널, Markdown, JUnit 리포트에 통과시킵니다. 스위트와 스냅샷 리더는 지나치게 큰 파일, 깊은 중첩, YAML 별칭 폭탄을 거부합니다.
- **모든 명령을 프로세스 안에서** 실행하며, OS 빌드를 지정한 스크립트 모델을 대상으로 합니다. 한 빌드에서 record하고 다른 빌드에서 run하는 경우, diff 정책, replay, 모델 없음, 읽을 수 없는 파일을 포함합니다.

테스트 107개는 Mac (Apple silicon), macOS 27.0.1, Xcode 27.1에서 모두 통과합니다. CI 워크플로는 Xcode 26.6과 Xcode 27에서 실행합니다.

## 제한 사항

- 라이브 실행에는 Apple silicon을 탑재하고 Apple Intelligence를 켠 Mac이 필요합니다. GitHub 호스팅 macOS 러너는 이를 갖추지 못한 가상 머신이며, 거기서는 fmdrift가 검증, replay, diff를 할 수 있습니다.
- OS 버전이 같더라도 Mac과 iPhone의 모델은 같은 방식으로 응답하지 않을 수 있습니다. fmdrift는 macOS에서만 실행되며, 모든 스냅샷에 출처가 된 Mac과 OS를 표시합니다.
- `refusal: true`는 `guardrailViolation` 또는 `refusal` 오류에서 통과합니다. 텍스트로 쓴 거절("죄송하지만 도와드릴 수 없습니다")은 일반적인 응답이므로 `containsAny`로 그 표현을 검사하세요. Apple은 텍스트 거절을 코드에서 항상 응답과 구별할 수는 없다고 밝힙니다.
- 지연 시간에는 세션 생성 시간이 포함됩니다. 모델을 불러오는 동안에는 실행의 첫 응답이 더 느릴 수 있습니다. 지연 시간은 같은 Mac에서 만든 스냅샷끼리 비교하세요.
- 출력 토큰 수는 macOS 27에서는 응답에서, macOS 26.4부터 26.x까지는 `tokenCount(for:)`에서 가져옵니다. 26.4 이전에는 `maxOutputTokens`를 건너뛰고 그 사실을 알려 줍니다.
- Apple의 [컨텍스트 윈도 문서](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)는 4,096 토큰이라고 하지만, macOS 27.0.1 (26A434)에서 `contextSize`는 8,192를 보고했습니다. `fmdrift doctor`는 지금 사용 중인 Mac의 값을 출력합니다.

## 요구 사항

| 플랫폼 | 최소 버전 |
| --- | --- |
| macOS (validate, replay, diff) | 26.0 |
| macOS (라이브 실행) | Apple silicon과 Apple Intelligence가 있는 26.0, 27.0.1에서 확인 |
| 툴체인 (소스에서 빌드) | Swift 6.2, Xcode 26.4 이상 |

## 아키텍처

- `Sources/FMDriftKit`: `SuiteLoader`가 스위트를 `Suite`와 `TestCase`로 읽어 들입니다. `Evaluator`와 `SchemaValidator`가 하나의 `Generation`을 검사합니다. `Runner`가 `ModelProvider`(온디바이스 모델용 `SystemModelProvider`, 스냅샷용 `ReplayProvider`)에 요청해 `RunResult`를 만듭니다. `SnapshotStore`가 그것을 읽고 쓰며, `SnapshotDiff`가 둘을 비교합니다. `Advice`가 실패를 Apple 문서에 연결하고, `Reports/`가 텍스트, Markdown, JUnit XML, JSON을 렌더링합니다.
- `Sources/FMDriftCLI`: 명령과 종료 코드를 담당하며, `Sources/fmdrift`는 이를 시작하기만 합니다.
- 각 generation은 새 `LanguageModelSession`을 사용하므로 어떤 케이스도 다른 케이스의 transcript를 보지 못합니다.
- macOS 27에서 오류가 `GenerationError`에서 `LanguageModelError`로 옮겨졌기 때문에, 오류는 case 이름으로 분류합니다. 같은 바이너리가 두 환경 모두에서 동작합니다.

## 문서

- [가이드](docs/guides/): 첫 번째 스위트 작성하기, OS 업데이트 후 드리프트 찾기, CI에서 fmdrift 사용하기.
- FMDriftKit의 [API와 스위트 형식](https://muhittincamdali.github.io/fmdrift/)(DocC).
- [예제](Examples/): 스냅샷이 포함된 support-app 스위트, FMDriftKit을 사용하는 Swift 프로그램, GitHub Actions 워크플로.
- [변경 이력](CHANGELOG.md).

## 참고 자료

fmdrift의 동작과 제안이 근거로 삼은 Apple 문서와 세션이며, 2026년 10월 28일에 확인했습니다.

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/): 모델 신호로서의 OS 버전(15:07), 연 2회 정도의 모델 업데이트, 베타 릴리스에서 진행
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) 및 [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## 기여하기

잘못된 판정을 보여 주는 스위트와 그 판정을 만든 스냅샷이 가장 큰 도움이 됩니다. 빌드, 테스트, 기록된 파일에 대해서는 [CONTRIBUTING.md](CONTRIBUTING.md)를, 취약점을 비공개로 제보하는 방법은 [SECURITY.md](SECURITY.md)를 참고하세요.

## 라이선스

[MIT](LICENSE)
