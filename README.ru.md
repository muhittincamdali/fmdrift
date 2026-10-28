<!-- i18n-source: README.md@9a56eea1e1d6d7b348e0f274964a3c1a0efb9b49 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-ru-light.svg" alt="Руководства"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

Встроенная в устройство foundation model от Apple меняется с обновлениями ОС, и Apple советует проверять
свои промпты на старой и на новой модели и сравнивать результат ([Updating prompts for new model
versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)).
fmdrift делает это из командной строки: запускает промпты из YAML-набора на модели того
Mac, где он работает, проверяет каждый ответ, записывает результаты для каждой сборки ОС и показывает, какие ответы
изменились или сломались в следующей сборке. На WWDC26 Apple спросили о версии модели во время выполнения, и она ответила,
что «практический сигнал на сегодня — версия ОС», поэтому fmdrift записывает именно её
([Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/), 15:07).

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="fmdrift run на примере support-app: пять кейсов, по три запуска каждый, все пройдены, для каждого кейса показаны согласованность и медианная задержка"></picture>

<sub>Записано настоящей командой на настоящей модели в устройстве (<code>node scripts/demo.mjs</code>)
на <a href="Examples/support-app">Examples/support-app</a>, macOS 27.0.1 (26A434), Mac17,6 (Apple
M5 Max).</sub>

## Основные возможности

- **Промпты и проверки в одном файле.** YAML-набор хранит каждый промпт вместе с инструкциями,
  параметрами сэмплирования, guardrails и сценарием использования, а также проверки, которые должны пройти его ответы: текст, регулярные
  выражения, значения JSON, длина, задержка, выходные токены и то, отказывается ли модель отвечать.
- **Структурированный вывод тоже.** Задайте для кейса JSON Schema, и fmdrift запросит guided generation
  (`DynamicGenerationSchema`), проверит результат по схеме и прочитает значения по пути.
- **Стабильность, а не один удачный ответ.** Каждый кейс можно запускать несколько раз в новых сессиях;
  в отчёте видно, сколько запусков прошло и сколько дало один и тот же ответ.
- **Снимки (snapshots) для каждой сборки ОС.** `record` сохраняет каждый ответ, задержку и число токенов в JSON в разделе
  той сборки ОС, которая их выдала. `run --baseline` и `diff` показывают, что регрессировало, изменилось или исправилось,
  с пословным diff ответов.
- **Исправление для каждой ошибки — с источником.** Нарушения guardrails, отказы, контекстное окно, языки,
  проблемы схемы, задержка и регрессии сопровождаются подсказкой со ссылкой на
  документацию Apple.
- **Создан для CI.** Вывод в терминал, Markdown, JUnit XML и JSON, а также коды выхода. Раннеры без
  Apple Intelligence всё равно могут проверять наборы и перепроверять записанные ответы.

## Быстрый старт

**1. Установите** (macOS 26 или новее, через [Homebrew](https://brew.sh)):

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. Напишите набор.** `fmdrift init` создаёт `fmdrift.yaml` с двумя рабочими кейсами; замените их
промптами, которые отправляет ваше приложение.

```sh
fmdrift init
```

**3. Запустите и запишите.** `fmdrift run` проверяет каждый ответ на модели этого Mac. `fmdrift record` сохраняет ответы для этой сборки ОС в `fmdrift-snapshots/`; закоммитьте эту папку. После
следующего обновления ОС `fmdrift run --baseline fmdrift-snapshots` покажет, что изменилось.

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor` сообщает, может ли этот Mac запустить модель и какую сборку ОС он запишет.
[Напишите свой первый набор](docs/guides/write-your-first-suite.md) проводит через это шаг за шагом.

## Что работает сейчас

| Возможность | Состояние |
| --- | --- |
| YAML- или JSON-наборы со значениями по умолчанию, инструкциями, сэмплированием, temperature, лимитом токенов ответа, guardrails и сценарием использования для каждого кейса | работает |
| Проверки: `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`, `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens`, `refusal` | работает |
| Guided generation по подмножеству JSON Schema, проверка схемы, проверки по пути JSON | работает |
| Повторы с требуемой долей успешных запусков и согласованность между запусками | работает |
| Снимки `record` для каждой сборки ОС; `run --baseline` и `diff` с регрессировавшими, изменившимися, исправленными, добавленными и удалёнными кейсами и лимитами задержки | работает |
| `run --replay`: перепроверка записанных ответов без модели | работает |
| Вывод в терминал, Markdown, JUnit XML и JSON; коды выхода 0, 1, 2 | работает |
| Библиотека FMDriftKit с документацией DocC | работает |
| Запуск набора на Private Cloud Compute или другом провайдере `LanguageModel` | запланировано (0.2) |
| Кейсы с tool-calling | запланировано (0.3) |

## fmdrift и Evaluations framework от Apple

В Xcode 27 появился [Evaluations framework](https://developer.apple.com/documentation/evaluations)
от Apple (macOS 27 и новее): оценки, написанные на Swift внутри тестового таргета, с моделями-судьями,
оценщиками tool-call и отчётами в Xcode. Используйте его, когда для проверок нужен код на Swift или модель-судья.
fmdrift решает ту же задачу с другой стороны:

- набор — это YAML-файл, который могут читать и редактировать люди, не пишущие на Swift;
- результаты — обычные JSON-файлы в git, по одному на сборку ОС, которые сравниваются из командной строки в любой
  системе CI;
- пакет собирается для macOS 26, где Evaluations framework недоступен, поэтому можно записать и
  ответы предыдущей модели (запуски на реальной модели в этом релизе проверены
  только на macOS 27.0.1).

## Установка

| Способ | Команда |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| Бинарный файл релиза | Скачайте `fmdrift-<version>-macos-arm64.tar.gz` со страницы [Releases](https://github.com/muhittincamdali/fmdrift/releases), сверьте его с `SHA256SUMS` и положите `fmdrift` в свой `PATH` |
| Из исходников | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release` (бинарный файл — `.build/release/fmdrift`) |
| Пакет Swift | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`, продукт `FMDriftKit` |

## Использование

### Как писать кейсы

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

Каждый ключ с его ограничениями описан в [справочнике по формату набора](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat).
`fmdrift validate` проверяет набор без модели и для неизвестного ключа называет тот, который вы,
вероятно, имели в виду.

### Сравнение сборок ОС

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

Кейс, который раньше проходил, а теперь падает, считается **регрессировавшим** (`regressed`) и приводит к ошибке запуска (код выхода 1).
`--fail-on changed` приводит к ошибке и при ответах, которые изменились, но всё ещё проходят, а
`--max-latency-increase 50%` — при кейсах, которые стали медленнее. Если между двумя запусками изменились промпт, инструкции, параметры или
схема, отчёт сообщает об этом, чтобы изменённый промпт не приняли за
новую модель.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="fmdrift run --baseline после сокращения инструкций: формулировка сводки тикета изменилась, а запрос не по теме, на который модель раньше отвечала текстовым отказом, теперь выбрасывает guardrailViolation и отмечается как регрессия"></picture>

<sub>Настоящий запуск на macOS 27.0.1 (26A434): инструкции примера сократили до «Answer in
at most eight words.» и сравнили с закоммиченным снимком. Запрос не по теме, на который
модель раньше отвечала текстом «Unable to work with that request.», теперь выбросил
<code>guardrailViolation</code>. Для этого релиза была доступна только одна сборка ОС, поэтому в этой демонстрации
меняется промпт, а не ОС; отчёт получается таким же.</sub>

### Проверка записанных ответов без модели

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay запускает проверки текущего набора на ответах из снимка. Это работает на любом Mac,
включая раннеры CI без Apple Intelligence, и выявляет проверку, которая больше не соответствует тому, что
сказала модель. Кейс, промпт которого изменился после записи, помечается.

### Отчёты для CI

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| Код выхода | Значение |
| --- | --- |
| 0 | Все кейсы прошли, регрессий нет |
| 1 | Кейс не прошёл или регрессировал (`validate`: набор некорректен; `doctor`: нет модели) |
| 2 | Неверные аргументы, нечитаемый набор или снимок, либо нет модели для запуска |

`--allow-unavailable` превращает отсутствие модели в заметку и код 0, для раннеров без Apple
Intelligence. В руководстве [fmdrift в CI](docs/guides/fmdrift-in-ci.md) есть полный рабочий процесс GitHub Actions.

## Как это тестируется

- **На настоящей модели.** [Examples/support-app](Examples/support-app) записан на macOS
  27.0.1 (26A434), Mac17,6 (Apple M5 Max): 15 генераций, все прошли, 9.70 s на весь запуск,
  медианы от 374 ms до 826 ms на ответ. Один тест при каждом запуске CI воспроизводит этот снимок через командную
  строку. Ещё два теста запрашивают у настоящей модели обычный и структурированный ответ,
  если задано `FMDRIFT_LIVE=1`.
- **Чему настоящая модель научила тесты.** Десять greedy-запусков промпта для сортировки обращений вернули
  одни и те же значения в четырёх разных порядках ключей, поэтому структурированные ответы сравниваются по значениям. Запрос
  не по теме был отклонён текстом, а не ошибкой, как и предупреждает
  [статья Apple о безопасности](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output),
  а с более короткими инструкциями тот же запрос выбросил `guardrailViolation`.
- **Каждый формат отчёта** побайтово сравнивается с файлами в
  [Fixtures/expected](Fixtures/expected), полученными из фиксированной baseline и текущего запуска, которые охватывают
  все виды результатов.
- **Недоверенный текст.** Вывод модели может содержать управляющие последовательности терминала, двунаправленные переопределения или
  разметку; тесты пропускают OSC 52, очистку экрана, переопределение справа налево, HTML и NUL через
  отчёты терминала, Markdown и JUnit. Чтение наборов и снимков отклоняет слишком большие файлы,
  глубокую вложенность и бомбы из YAML-алиасов.
- **Каждая команда в одном процессе**, против сценарной модели с выбранной сборкой ОС, включая
  запись на одной сборке, запуск на другой, политики diff, replay, отсутствие модели и
  нечитаемые файлы.

112 тестов. Все проходят на Mac (Apple silicon) с macOS 27.0.1 и Xcode 27.1; CI-процесс запускает
их с Xcode 26.6 и Xcode 27.

## Ограничения

- Для запусков на реальной модели нужен Mac на Apple silicon с включённым Apple Intelligence. Раннеры macOS,
  размещённые на GitHub, — это виртуальные машины без него; на них fmdrift умеет проверять наборы, воспроизводить через replay и сравнивать через diff.
- Модель на Mac и на iPhone с той же версией ОС может отвечать по-разному.
  fmdrift работает только на macOS и помечает каждый снимок Mac и ОС, с которых он получен.
- `refusal: true` проходит при ошибке `guardrailViolation` или `refusal`. Отказ, написанный текстом
  («Извините, с этим я помочь не могу»), — это обычный ответ: проверяйте его слова через `containsAny`.
  Apple отмечает, что отказ в виде текста не всегда можно отличить от ответа в коде.
- Задержка включает создание сессии; первый ответ запуска может быть медленнее, пока загружается модель.
  Сравнивайте задержку между снимками с одного и того же Mac.
- Число выходных токенов берётся из ответа на macOS 27 и из `tokenCount(for:)` на macOS
  26.4–26.x; до 26.4 `maxOutputTokens` пропускается, и об этом сообщается.
- [Статья о контекстном окне](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
  от Apple называет 4,096 токенов; `contextSize` на macOS 27.0.1 (26A434) показал 8,192. `fmdrift doctor`
  выводит значение для того Mac, на котором вы работаете.

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| macOS (validate, replay, diff) | 26.0 |
| macOS (запуски на реальной модели) | 26.0 на Apple silicon с Apple Intelligence; проверено на 27.0.1 |
| Инструменты (сборка из исходников) | Swift 6.2, Xcode 26.4 или новее |

## Архитектура

- `Sources/FMDriftKit`: `SuiteLoader` читает наборы в `Suite` и `TestCase`; `Evaluator` и
  `SchemaValidator` проверяют одну `Generation`; `Runner` обращается к `ModelProvider`
  (`SystemModelProvider` для модели в устройстве, `ReplayProvider` для снимков) и строит
  `RunResult`; `SnapshotStore` читает и записывает его; `SnapshotDiff` сравнивает два результата; `Advice` сопоставляет
  ошибки с документацией Apple; `Reports/` формирует текст, Markdown, JUnit XML и JSON.
- `Sources/FMDriftCLI`: команды и коды выхода; `Sources/fmdrift` лишь запускает их.
- Каждая генерация использует новую `LanguageModelSession`, поэтому ни один кейс не видит transcript другого.
- Ошибки классифицируются по имени case, потому что macOS 27 перенесла их из `GenerationError` в
  `LanguageModelError`; один и тот же бинарный файл работает на обеих.

## Документация

- [Руководства](docs/guides/): первый набор, поиск дрейфа после обновления ОС, fmdrift в CI.
- [API и формат набора](https://muhittincamdali.github.io/fmdrift/) (DocC) для FMDriftKit.
- [Примеры](Examples/): набор support-app со снимком, программа на Swift на базе FMDriftKit,
  рабочий процесс GitHub Actions.
- [Журнал изменений](CHANGELOG.md).

## Источники

Документация и сессии Apple, на которых основаны поведение и подсказки fmdrift; прочитаны 28 октября 2026 года:

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/): версия ОС как сигнал о модели (15:07), около двух обновлений модели в год, выходят в бета-версиях
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) и [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## Участие в разработке

Больше всего помогает набор, показывающий неверный вердикт, вместе со снимком, который его дал. Сборка, тесты и
записанные файлы описаны в [CONTRIBUTING.md](CONTRIBUTING.md), а о том, как сообщить об уязвимости
конфиденциально, — в [SECURITY.md](SECURITY.md).

## Лицензия

[MIT](LICENSE)
