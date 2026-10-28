<!-- i18n-source: README.md@ac64b25b73193784abe7b1fbd7738ac6a9609362 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ja-light.svg" alt="ガイド"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

Apple のオンデバイス基盤モデル（foundation model）は OS のアップデートとともに変わります。Apple は、旧モデルと新モデルの両方でプロンプトをテストし、出力を比較することを勧めています（[Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)）。fmdrift はこれをコマンドラインから行います。YAML のスイートに書いたプロンプトを実行している Mac のモデルで実行し、すべての回答を検査し、結果を OS ビルドごとに記録して、次のビルドでどの回答が変化したか、あるいは壊れたかを示します。WWDC26 でランタイムのモデルバージョンについて尋ねられた Apple は「現時点で実用的なシグナルは OS のバージョンです」と答えました。そのため fmdrift は OS のバージョンを記録します（[Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/)、15:07）。

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="support-app サンプルでの fmdrift run：5 つのケースを各 3 回実行してすべて合格し、ケースごとの一致度と中央値のレイテンシが表示されている"></picture>

<sub>実際のコマンドとオンデバイスの実モデルから記録（<code>node scripts/demo.mjs</code>）。対象は <a href="Examples/support-app">Examples/support-app</a>、環境は macOS 27.0.1 (26A434)、Mac17,6（Apple M5 Max）です。</sub>

## 主な特長

- **プロンプトと検査を 1 つのファイルに。** YAML のスイートには、各プロンプトとその instructions、サンプリング設定、guardrail、ユースケースに加え、回答が通過すべき検査（テキスト、正規表現、JSON の値、長さ、レイテンシ、出力トークン数、モデルが回答を拒否したかどうか）を書きます。
- **構造化出力にも対応。** ケースに JSON Schema を指定すると、fmdrift は guided generation（`DynamicGenerationSchema`）を要求し、結果をスキーマに照らして検査し、パスで値を読み取ります。
- **たまたま 1 回うまくいった回答ではなく、安定性を見る。** 各ケースは新しいセッションで複数回実行できます。レポートには、何回合格したか、何回が同じ回答だったかが表示されます。
- **OS ビルドごとのスナップショット。** `record` は、すべての回答、レイテンシ、トークン数を、それを生成した OS ビルドの下に JSON として保存します。`run --baseline` と `diff` は、どこが回帰し、変化し、修正されたかを、回答の単語単位の差分とともに表示します。
- **失敗ごとに、出典付きの対処方法を提示。** guardrail 違反、拒否、コンテキストウィンドウ、言語、スキーマの問題、レイテンシ、回帰のそれぞれに、Apple のドキュメントへのリンク付きで提案が表示されます。
- **CI 向けに設計。** ターミナル、Markdown、JUnit XML、JSON の出力と終了コードに対応します。Apple Intelligence のないランナーでも、スイートの検証と、記録済みの回答の再検査ができます。

## クイックスタート

**1. インストールする**（macOS 26 以降、[Homebrew](https://brew.sh) を使用）：

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. スイートを書く。** `fmdrift init` は、動作する 2 つのケースを含む `fmdrift.yaml` を書き出します。これをアプリが送信するプロンプトに置き換えてください。

```sh
fmdrift init
```

**3. 実行して記録する。** `fmdrift run` は、この Mac のモデルですべての回答を検査します。`fmdrift record` は、この OS ビルドの回答を `fmdrift-snapshots/` に保存します。このフォルダはコミットしてください。次の OS アップデートの後に `fmdrift run --baseline fmdrift-snapshots` を実行すると、何が変わったかがわかります。

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor` は、この Mac でモデルを実行できるかどうかと、どの OS ビルドとして記録されるかを表示します。[最初のスイートを書く](docs/guides/write-your-first-suite.md)では、手順を 1 つずつ説明しています。

## 現在動作するもの

| 機能 | 状況 |
| --- | --- |
| デフォルト値、およびケースごとの instructions、サンプリング、temperature、応答トークン数の上限、guardrail、ユースケースを持つ YAML または JSON のスイート | 動作します |
| 検査：`contains`、`containsAny`、`notContains`、`equals`、`oneOf`、`matches`、`notMatches`、`minLength`、`maxLength`、`atLeast`、`atMost`、`maxLatency`、`maxOutputTokens`、`refusal` | 動作します |
| JSON Schema のサブセットによる guided generation、スキーマ検証、JSON パスによる検査 | 動作します |
| 必要な合格率を指定した繰り返し実行と、実行間の一致度 | 動作します |
| OS ビルドごとの `record` スナップショット。回帰、変化、修正、追加、削除されたケースとレイテンシの上限を表示する `run --baseline` と `diff` | 動作します |
| `run --replay`：モデルなしで記録済みの回答を再検査 | 動作します |
| ターミナル、Markdown、JUnit XML、JSON の出力。終了コード 0、1、2 | 動作します |
| DocC ドキュメント付きの FMDriftKit ライブラリ | 動作します |
| Private Cloud Compute や他の `LanguageModel` プロバイダでスイートを実行 | 計画中（0.2） |
| tool-calling のケース | 計画中（0.3） |

## fmdrift と Apple の Evaluations framework

Xcode 27 で Apple の [Evaluations framework](https://developer.apple.com/documentation/evaluations) が追加されました（macOS 27 以降）。テストターゲット内で Swift で書く評価で、モデルによる判定、tool-call の評価器、Xcode でのレポートを備えています。検査に Swift のコードや判定用モデルが必要な場合は、そちらを使ってください。fmdrift は、同じ仕事のもう一方の側のためのものです。

- スイートは YAML ファイルなので、Swift を書かない人でも読んだり編集したりできます。
- 結果は git に置く単純な JSON ファイル（OS ビルドごとに 1 つ）で、どの CI システムでもコマンドラインから比較できます。
- パッケージは Evaluations framework が使えない macOS 26 向けにもビルドできるため、以前のモデルの回答も記録できます（このリリースでの実機実行は macOS 27.0.1 でのみ確認しました）。

## インストール

| 方法 | コマンド |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| リリースバイナリ | [Releases](https://github.com/muhittincamdali/fmdrift/releases) から `fmdrift-<version>-macos-arm64.tar.gz` をダウンロードし、`SHA256SUMS` で確認して、`fmdrift` を `PATH` の通った場所に置きます |
| ソースから | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release`（バイナリは `.build/release/fmdrift`） |
| Swift パッケージ | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`、プロダクトは `FMDriftKit` |

## 使い方

### ケースを書く

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

すべてのキーとその制限は、[スイート形式のリファレンス](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat)にあります。`fmdrift validate` はモデルなしでスイートを検査し、未知のキーについては、おそらく意図したキーを示します。

### OS ビルドを比較する

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

以前は合格していて今回失敗したケースは**回帰**（`regressed`）となり、実行は失敗します（終了ステータス 1）。`--fail-on changed` は、回答が変化したものの合格しているケースでも失敗とし、`--max-latency-increase 50%` は遅くなったケースを失敗とします。2 回の実行の間にプロンプト、instructions、オプション、スキーマのいずれかが変更されていた場合、レポートはそのことを示します。そのため、編集したプロンプトを新しいモデルによる変化と取り違えることはありません。

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="instructions を短くした後の fmdrift run --baseline：チケット要約の言い回しが変わり、これまでモデルがテキストで断っていた話題外のリクエストが guardrailViolation をスローするようになり、回帰として報告されている"></picture>

<sub>macOS 27.0.1 (26A434) での実際の実行です。サンプルの instructions を "Answer in at most eight words." に短縮し、コミット済みのスナップショットと比較しました。モデルがこれまで "Unable to work with that request." というテキストで断っていた話題外のリクエストが、<code>guardrailViolation</code> をスローするようになりました。このリリースで利用できた OS ビルドは 1 つだけだったため、このデモでは OS ではなくプロンプトを変えています。レポートの内容は同じです。</sub>

### モデルなしで記録済みの回答を検査する

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay は、現在のスイートの検査をスナップショット内の回答に対して実行します。Apple Intelligence のない CI ランナーを含め、どの Mac でも動作し、モデルの実際の回答と合わなくなった検査を見つけます。記録後にプロンプトが変更されたケースには印が付きます。

### CI 向けのレポート

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| 終了ステータス | 意味 |
| --- | --- |
| 0 | すべてのケースが合格し、回帰はない |
| 1 | ケースが失敗または回帰した（`validate`：スイートが無効、`doctor`：モデルがない） |
| 2 | 引数が正しくない、スイートまたはスナップショットを読み込めない、または実行できるモデルがない |

`--allow-unavailable` は、モデルがない状態をメモとして扱い、ステータス 0 にします。Apple Intelligence のないランナー向けです。[CI での fmdrift](docs/guides/fmdrift-in-ci.md)に、GitHub Actions のワークフロー全体を載せています。

## テスト方法

- **実際のモデルで。** [Examples/support-app](Examples/support-app) は macOS 27.0.1 (26A434)、Mac17,6（Apple M5 Max）で記録しました。生成は 15 回で、すべて合格し、実行全体で 9.70 s、回答ごとの中央値は 374 ms から 826 ms でした。CI の実行ごとに、あるテストがこのスナップショットをコマンドライン経由でリプレイします。`FMDRIFT_LIVE=1` を設定すると、さらに 2 つのテストが実モデルに通常の回答と構造化された回答を求めます。
- **実モデルがテストに教えてくれたこと。** トリアージ用プロンプトを greedy で 10 回実行したところ、同じ値が 4 通りの異なるキー順で返りました。そのため、構造化された回答は値で比較します。話題外のリクエストは、Apple の[安全性に関する記事](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)が警告するとおり、エラーではなくテキストで断られました。instructions を短くすると、同じリクエストは `guardrailViolation` をスローしました。
- **すべてのレポート形式**を、[Fixtures/expected](Fixtures/expected) のファイルとバイト単位で比較しています。これらは、あらゆる種類の結果を含む固定のベースラインと現在の実行から作られています。
- **信頼できないテキスト。** モデルの出力には、ターミナルのエスケープシーケンス、双方向テキストの上書き、マークアップが含まれることがあります。テストでは、OSC 52、画面クリア、右から左への上書き、HTML、NUL をターミナル、Markdown、JUnit のレポートに通します。スイートとスナップショットのリーダーは、過大なファイル、深いネスト、YAML のエイリアスボムを拒否します。
- **すべてのコマンドをプロセス内で**、OS ビルドを指定したスクリプト化モデルに対して実行します。あるビルドでの record、別のビルドでの run、diff のポリシー、replay、モデルがない場合、読み込めないファイルを含みます。

107 件のテストは、Mac (Apple silicon)、macOS 27.0.1、Xcode 27.1 ですべて成功します。CI ワークフローは Xcode 26.6 と Xcode 27 で実行します。

## 制限事項

- 実機での実行には、Apple silicon を搭載し Apple Intelligence をオンにした Mac が必要です。GitHub ホストの macOS ランナーはそれを持たない仮想マシンなので、そこでは fmdrift は検証、replay、diff を行えます。
- 同じ OS バージョンの Mac と iPhone で、モデルが同じ回答を返すとは限りません。fmdrift は macOS でのみ動作し、すべてのスナップショットに、取得元の Mac と OS を記録します。
- `refusal: true` は、`guardrailViolation` または `refusal` エラーのときに合格します。テキストで書かれた拒否（「申し訳ありませんが、お手伝いできません」）は通常の回答として扱われるため、その文言を `containsAny` で検査してください。Apple は、テキストによる拒否を、コード上で常に回答と区別できるとは限らないと述べています。
- レイテンシにはセッションの作成時間が含まれます。モデルの読み込み中は、実行の最初の回答が遅くなることがあります。レイテンシは同じ Mac のスナップショット同士で比較してください。
- 出力トークン数は、macOS 27 では応答から、macOS 26.4 から 26.x では `tokenCount(for:)` から取得します。26.4 より前では `maxOutputTokens` はスキップされ、その旨が表示されます。
- Apple の[コンテキストウィンドウの記事](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)では 4,096 トークンとされていますが、macOS 27.0.1 (26A434) では `contextSize` が 8,192 を返しました。`fmdrift doctor` は、お使いの Mac の値を表示します。

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| macOS（validate、replay、diff） | 26.0 |
| macOS（実機での実行） | Apple silicon と Apple Intelligence を備えた 26.0。27.0.1 で確認 |
| ツールチェーン（ソースからのビルド） | Swift 6.2、Xcode 26.4 以降 |

## アーキテクチャ

- `Sources/FMDriftKit`：`SuiteLoader` がスイートを `Suite` と `TestCase` に読み込みます。`Evaluator` と `SchemaValidator` が 1 つの `Generation` を検査します。`Runner` が `ModelProvider`（オンデバイスモデル用の `SystemModelProvider`、スナップショット用の `ReplayProvider`）に問い合わせて `RunResult` を作ります。`SnapshotStore` がそれを読み書きし、`SnapshotDiff` が 2 つを比較します。`Advice` が失敗を Apple のドキュメントに対応付け、`Reports/` がテキスト、Markdown、JUnit XML、JSON を出力します。
- `Sources/FMDriftCLI`：コマンドと終了コード。`Sources/fmdrift` はそれらを起動するだけです。
- 各 generation は新しい `LanguageModelSession` を使うため、他のケースの transcript が見えるケースはありません。
- macOS 27 でエラーが `GenerationError` から `LanguageModelError` に移ったため、エラーは case 名で分類しています。同じバイナリが両方で動作します。

## ドキュメント

- [ガイド](docs/guides/)：最初のスイートを書く、OS アップデート後にドリフトを見つける、CI での fmdrift。
- FMDriftKit の [API とスイート形式](https://muhittincamdali.github.io/fmdrift/)（DocC）。
- [サンプル](Examples/)：スナップショット付きの support-app スイート、FMDriftKit を使う Swift プログラム、GitHub Actions のワークフロー。
- [変更履歴](CHANGELOG.md)。

## 参考資料

fmdrift の動作と提案の根拠とした Apple のドキュメントとセッションです（2026 年 10 月 28 日に確認）：

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/)：モデルのシグナルとしての OS バージョン（15:07）、モデルの更新は年に 2 回ほどで、ベータ版で行われる
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) と [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## コントリビューション

もっとも助かるのは、誤った判定を示すスイートと、その判定を生んだスナップショットです。ビルド、テスト、記録されるファイルについては [CONTRIBUTING.md](CONTRIBUTING.md) を、脆弱性を非公開で報告する方法については [SECURITY.md](SECURITY.md) を参照してください。

## ライセンス

[MIT](LICENSE)
