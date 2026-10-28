<!-- i18n-source: README.md@ac64b25b73193784abe7b1fbd7738ac6a9609362 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-zh-CN-light.svg" alt="指南"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

Apple 的设备端 foundation model 会随系统更新而变化，Apple 的建议是：在旧模型和新模型上分别测试你的提示词，并比较输出（[Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)）。fmdrift 在命令行中完成这件事：它在所运行 Mac 的模型上执行 YAML 测试套件中的提示词，检查每一条回答，按系统 build 记录结果，并在下一个 build 上显示哪些回答发生了变化或出现了问题。在 WWDC26 上有人询问是否能获取运行时的模型版本，Apple 的回答是“目前切实可用的信号就是系统版本”，因此 fmdrift 记录的正是系统版本（[Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/)，15:07）。

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="fmdrift 在 support-app 示例上运行：五个用例，每个运行三次，全部通过，并显示每个用例的一致性和延迟中位数"></picture>

<sub>录制自真实的命令和设备端的真实模型（<code>node scripts/demo.mjs</code>），运行于 <a href="Examples/support-app">Examples/support-app</a>，环境为 macOS 27.0.1 (26A434)、Mac17,6（Apple M5 Max）。</sub>

## 亮点

- **提示词和检查项放在同一个文件中。** YAML 测试套件为每个提示词保存其指令、采样设置、guardrail 和用途，以及回答必须通过的检查：文本、正则表达式、JSON 值、长度、延迟、输出 token 数，以及模型是否拒绝回答。
- **同样支持结构化输出。** 为用例提供 JSON Schema，fmdrift 就会请求 guided generation（`DynamicGenerationSchema`），按该 schema 检查结果，并通过路径读取其中的值。
- **看重稳定性，而不是一次碰巧的回答。** 每个用例可以在新会话中运行多次，报告会显示有多少次通过、有多少次给出了相同的回答。
- **按系统 build 保存快照。** `record` 会把每条回答、延迟和 token 数以 JSON 形式保存在产生它的系统 build 名下。`run --baseline` 和 `diff` 会显示哪些用例出现了退化、变化或已修复，并附上回答的逐词差异。
- **每个失败都附带修复建议及其出处。** guardrail 违规、拒绝回答、上下文窗口、语言、schema 问题、延迟和退化都会给出一条建议，并链接到 Apple 的文档。
- **为 CI 而设计。** 提供终端、Markdown、JUnit XML 和 JSON 输出以及退出码。没有 Apple Intelligence 的 runner 依然可以验证测试套件，并重新检查已记录的回答。

## 快速开始

**1. 安装**（macOS 26 或更高版本，使用 [Homebrew](https://brew.sh)）：

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. 编写测试套件。** `fmdrift init` 会写入带有两个可运行用例的 `fmdrift.yaml`；请把它们替换成你的应用实际发送的提示词。

```sh
fmdrift init
```

**3. 运行并记录。** `fmdrift run` 会在这台 Mac 的模型上检查每一条回答。`fmdrift record` 会把当前系统 build 的回答保存到 `fmdrift-snapshots/`，请提交该文件夹。下次系统更新之后，运行 `fmdrift run --baseline fmdrift-snapshots` 即可看到发生了什么变化。

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor` 会说明这台 Mac 能否运行该模型，以及它将记录哪个系统 build。[编写你的第一个测试套件](docs/guides/write-your-first-suite.md)会一步一步带你完成。

## 目前可用的功能

| 功能 | 状态 |
| --- | --- |
| YAML 或 JSON 测试套件，支持默认值，以及每个用例的指令、采样、temperature、响应 token 上限、guardrail 和用途 | 可用 |
| 检查项：`contains`、`containsAny`、`notContains`、`equals`、`oneOf`、`matches`、`notMatches`、`minLength`、`maxLength`、`atLeast`、`atMost`、`maxLatency`、`maxOutputTokens`、`refusal` | 可用 |
| 基于 JSON Schema 子集的 guided generation、schema 校验、按 JSON 路径检查 | 可用 |
| 带必需通过率的重复运行，以及多次运行之间的一致性 | 可用 |
| 按系统 build 保存的 `record` 快照；`run --baseline` 和 `diff` 可显示退化、变化、已修复、新增和已移除的用例以及延迟上限 | 可用 |
| `run --replay`：无需模型即可重新检查已记录的回答 | 可用 |
| 终端、Markdown、JUnit XML 和 JSON 输出；退出码 0、1、2 | 可用 |
| 带 DocC 文档的 FMDriftKit 库 | 可用 |
| 在 Private Cloud Compute 或其他 `LanguageModel` 提供方上运行测试套件 | 计划中（0.2） |
| 工具调用（tool-calling）用例 | 计划中（0.3） |

## fmdrift 与 Apple 的 Evaluations framework

Xcode 27 新增了 Apple 的 [Evaluations framework](https://developer.apple.com/documentation/evaluations)（macOS 27 及更高版本）：评估用 Swift 编写在测试 target 中，带有模型评审、tool-call 评估器，以及 Xcode 中的报告。如果你的检查需要 Swift 代码或评审模型，请使用它。fmdrift 面向同一件事的另一面：

- 测试套件是一个 YAML 文件，不写 Swift 的人也能阅读和编辑，
- 结果是存放在 git 中的普通 JSON 文件，每个系统 build 一个，可以在任何 CI 系统中通过命令行进行比较，
- 该软件包可在 macOS 26 上构建，而那里没有 Evaluations framework，因此也能记录更早模型的回答（本版本的实机运行只在 macOS 27.0.1 上验证过）。

## 安装

| 方式 | 命令 |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| 发布版二进制文件 | 从 [Releases](https://github.com/muhittincamdali/fmdrift/releases) 下载 `fmdrift-<version>-macos-arm64.tar.gz`，用 `SHA256SUMS` 校验，然后把 `fmdrift` 放到 `PATH` 中 |
| 从源码构建 | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release`（二进制文件位于 `.build/release/fmdrift`） |
| Swift 软件包 | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`，产品为 `FMDriftKit` |

## 使用方法

### 编写用例

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

每个键及其限制都记录在[测试套件格式参考](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat)中。`fmdrift validate` 无需模型即可检查测试套件，并会指出未知的键以及你很可能想写的那个键。

### 比较系统 build

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

以前通过、现在失败的用例会被标记为**退化**（`regressed`），并使本次运行失败（退出状态 1）。`--fail-on changed` 还会让回答已改变但仍然通过的用例导致失败，`--max-latency-increase 50%` 则会让变慢的用例导致失败。如果两次运行之间提示词、指令、选项或 schema 发生了变化，报告会注明这一点，这样就不会把修改过的提示词误认为是新模型。

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="缩短指令后运行 fmdrift run --baseline：工单摘要的措辞发生了变化，而模型原本会用文字拒绝的离题请求现在会抛出 guardrailViolation，并被报告为退化"></picture>

<sub>在 macOS 27.0.1 (26A434) 上的一次真实运行：示例的指令被缩短为 "Answer in at most eight words."，并与已提交的快照进行比较。模型原本以文字 "Unable to work with that request." 拒绝的离题请求，现在抛出了 <code>guardrailViolation</code>。本版本只有一个系统 build 可用，所以这个演示改变的是提示词而不是系统；报告的形式是一样的。</sub>

### 无需模型即可检查已记录的回答

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay 会把当前测试套件的检查项应用到快照中的回答上。它可以在任何 Mac 上运行，包括没有 Apple Intelligence 的 CI runner，并能发现已不再匹配模型实际回答的检查项。录制之后提示词发生变化的用例会被标出。

### 用于 CI 的报告

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| 退出状态 | 含义 |
| --- | --- |
| 0 | 所有用例都通过，且没有退化 |
| 1 | 有用例失败或退化（`validate`：测试套件无效；`doctor`：没有模型） |
| 2 | 参数错误、测试套件或快照无法读取，或者没有可运行的模型 |

`--allow-unavailable` 会把缺少模型变成一条提示并返回状态 0，适用于没有 Apple Intelligence 的 runner。[在 CI 中使用 fmdrift](docs/guides/fmdrift-in-ci.md) 提供了完整的 GitHub Actions 工作流。

## 测试方式

- **在真实模型上。** [Examples/support-app](Examples/support-app) 录制于 macOS 27.0.1 (26A434)、Mac17,6（Apple M5 Max）：共 15 次生成，全部通过，整个运行耗时 9.70 s，每条回答的中位数在 374 ms 到 826 ms 之间。每次 CI 运行时，都有一个测试通过命令行回放该快照。设置 `FMDRIFT_LIVE=1` 后，另有两个测试会向真实模型请求一条普通回答和一条结构化回答。
- **真实模型给测试带来的启示。** 对分诊提示词进行十次 greedy 运行，返回的值相同，但键的顺序有四种，因此结构化回答按值比较。正如 Apple 的[安全性文章](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)所警告的那样，离题请求是被文字拒绝的，而不是抛出错误；指令缩短之后，同一个请求则抛出了 `guardrailViolation`。
- **每种报告格式**都与 [Fixtures/expected](Fixtures/expected) 中的文件逐字节比较，这些文件由一个固定的基线和一次当前运行生成，涵盖每一种结果类型。
- **不可信文本。** 模型输出可能带有终端转义序列、双向文本覆盖或标记；测试会把 OSC 52、清屏、从右到左覆盖、HTML 和 NUL 送入终端、Markdown 和 JUnit 报告。测试套件和快照读取器会拒绝过大的文件、过深的嵌套和 YAML 别名炸弹。
- **每条命令都在进程内运行**，对象是指定了系统 build 的脚本化模型，包括在一个 build 上记录、在另一个 build 上运行、diff 策略、replay、缺少模型以及无法读取的文件。

共 107 个测试，在 Mac (Apple silicon)、macOS 27.0.1、Xcode 27.1 上全部通过；CI 工作流使用 Xcode 26.6 和 Xcode 27 运行它们。

## 限制

- 实机运行需要搭载 Apple silicon 且已开启 Apple Intelligence 的 Mac。GitHub 托管的 macOS runner 是没有这些功能的虚拟机；在那里 fmdrift 可以验证、回放和 diff。
- 相同系统版本的 Mac 和 iPhone 上的模型，回答不一定相同。fmdrift 只在 macOS 上运行，并为每个快照标注其来源的 Mac 和系统。
- `refusal: true` 在出现 `guardrailViolation` 或 `refusal` 错误时通过。以文字写出的拒绝（“抱歉，我无法帮助处理这个请求”）属于普通回答：请用 `containsAny` 检查其用词。Apple 指出，在代码中并不总能把文字形式的拒绝与回答区分开。
- 延迟包含创建会话的时间；模型加载期间，一次运行的第一条回答可能更慢。请在同一台 Mac 的快照之间比较延迟。
- 输出 token 数在 macOS 27 上取自响应，在 macOS 26.4 到 26.x 上取自 `tokenCount(for:)`；26.4 之前会跳过 `maxOutputTokens`，并明确说明。
- Apple 的[上下文窗口文章](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)给出的是 4,096 个 token；在 macOS 27.0.1 (26A434) 上，`contextSize` 报告的是 8,192。`fmdrift doctor` 会输出当前这台 Mac 的值。

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| macOS（validate、replay、diff） | 26.0 |
| macOS（实机运行） | 26.0，需 Apple silicon 并开启 Apple Intelligence；已在 27.0.1 上验证 |
| 工具链（从源码构建） | Swift 6.2，Xcode 26.4 或更高版本 |

## 架构

- `Sources/FMDriftKit`：`SuiteLoader` 把测试套件读入 `Suite` 和 `TestCase`；`Evaluator` 和 `SchemaValidator` 检查单个 `Generation`；`Runner` 向 `ModelProvider` 发起请求（设备端模型用 `SystemModelProvider`，快照用 `ReplayProvider`）并生成 `RunResult`；`SnapshotStore` 负责读写；`SnapshotDiff` 比较两份结果；`Advice` 把失败映射到 Apple 的文档；`Reports/` 渲染文本、Markdown、JUnit XML 和 JSON。
- `Sources/FMDriftCLI`：各个命令和退出码；`Sources/fmdrift` 只负责启动它们。
- 每次生成都使用新的 `LanguageModelSession`，因此没有任何用例能看到其他用例的 transcript。
- 错误按 case 名称分类，因为 macOS 27 把它们从 `GenerationError` 移到了 `LanguageModelError`；同一个二进制文件在两者上都能工作。

## 文档

- [指南](docs/guides/)：编写第一个测试套件、在系统更新后发现漂移、在 CI 中使用 fmdrift。
- FMDriftKit 的 [API 与测试套件格式](https://muhittincamdali.github.io/fmdrift/)（DocC）。
- [示例](Examples/)：带快照的 support-app 测试套件、基于 FMDriftKit 的 Swift 程序、一个 GitHub Actions 工作流。
- [更新日志](CHANGELOG.md)。

## 参考资料

fmdrift 的行为和建议所依据的 Apple 文档与会议，阅读于 2026 年 10 月 28 日：

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/)：以系统版本作为模型信号（15:07），每年大约两次模型更新，在 beta 版本中进行
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)和 [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## 参与贡献

最有帮助的是一个会给出错误结论的测试套件，以及产生该结论的快照。构建、测试和已记录文件请见 [CONTRIBUTING.md](CONTRIBUTING.md)，私下报告安全漏洞请见 [SECURITY.md](SECURITY.md)。

## 许可证

[MIT](LICENSE)
