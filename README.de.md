<!-- i18n-source: README.md@f4a2589fd7640b054cafe0fe7d23b6031a10affa status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-de-light.svg" alt="Anleitungen"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

Das Foundation Model, das Apple auf dem Gerät ausführt, ändert sich mit Betriebssystem-Updates, und Apple rät, die eigenen
Prompts mit dem alten und dem neuen Modell zu testen und die Ausgaben zu vergleichen ([Updating prompts for new model
versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)).
fmdrift erledigt das auf der Kommandozeile: Es führt die Prompts einer YAML-Suite mit dem Modell des
Macs aus, auf dem es läuft, prüft jede Antwort, speichert die Ergebnisse pro Betriebssystem-Build und zeigt, welche Antworten
sich beim nächsten Build geändert haben oder fehlschlagen. Auf der WWDC26 nach einer Modellversion zur Laufzeit gefragt, antwortete Apple,
„das praktische Signal ist heute die Betriebssystemversion“, und genau die zeichnet fmdrift auf
([Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/), 15:07).

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="fmdrift run für das Beispiel support-app: fünf Testfälle mit je drei Durchläufen, alle bestanden, mit Übereinstimmung und Median-Latenz pro Testfall"></picture>

<sub>Aufgezeichnet mit dem echten Befehl und dem echten Modell auf dem Gerät (<code>node scripts/demo.mjs</code>)
anhand von <a href="Examples/support-app">Examples/support-app</a>, unter macOS 27.0.1 (26A434), Mac17,6 (Apple
M5 Max).</sub>

## Highlights

- **Prompts und Prüfungen in einer Datei.** Eine YAML-Suite enthält jeden Prompt mit seinen Anweisungen,
  Sampling, Guardrails und Anwendungsfall sowie die Prüfungen, die seine Antworten bestehen müssen: Text, reguläre
  Ausdrücke, JSON-Werte, Länge, Latenz, Ausgabe-Tokens und ob das Modell ablehnt.
- **Auch strukturierte Ausgabe.** Gib einem Testfall ein JSON Schema, und fmdrift fordert Guided Generation
  (`DynamicGenerationSchema`) an, prüft das Ergebnis gegen das Schema und liest Werte über einen Pfad.
- **Stabilität statt einer glücklichen Antwort.** Jeder Testfall kann mehrfach in neuen Sessions laufen;
  der Bericht zeigt, wie viele Durchläufe bestanden haben und wie viele dieselbe Antwort geliefert haben.
- **Snapshots pro Betriebssystem-Build.** `record` speichert jede Antwort, Latenz und Token-Anzahl als JSON unter
  dem Betriebssystem-Build, der sie erzeugt hat. `run --baseline` und `diff` zeigen, was sich verschlechtert, geändert oder verbessert hat,
  mit einem Wort-Diff der Antworten.
- **Zu jedem Fehler eine Lösung samt Quelle.** Guardrail-Verstöße, Ablehnungen, Kontextfenster, Sprachen,
  Schemaprobleme, Latenz und Regressionen kommen jeweils mit einem Vorschlag, der auf
  Apples Dokumentation verweist.
- **Für CI gemacht.** Ausgabe als Terminal-Text, Markdown, JUnit XML und JSON sowie Exit-Codes. Runner ohne
  Apple Intelligence können Suites trotzdem validieren und aufgezeichnete Antworten erneut prüfen.

## Schnellstart

**1. Installieren** (macOS 26 oder neuer, mit [Homebrew](https://brew.sh)):

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. Eine Suite schreiben.** `fmdrift init` schreibt `fmdrift.yaml` mit zwei funktionierenden Testfällen; ersetze sie
durch die Prompts, die deine App sendet.

```sh
fmdrift init
```

**3. Ausführen und aufzeichnen.** `fmdrift run` prüft jede Antwort mit dem Modell dieses Macs. `fmdrift record` speichert die Antworten für diesen Betriebssystem-Build in `fmdrift-snapshots/`; committe diesen Ordner. Nach dem
nächsten Betriebssystem-Update zeigt `fmdrift run --baseline fmdrift-snapshots`, was sich geändert hat.

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor` sagt, ob dieser Mac das Modell ausführen kann und welchen Betriebssystem-Build er aufzeichnen würde.
[Deine erste Suite schreiben](docs/guides/write-your-first-suite.md) führt Schritt für Schritt hindurch.

## Was heute funktioniert

| Funktion | Status |
| --- | --- |
| YAML- oder JSON-Suites mit Standardwerten, Anweisungen, Sampling, Temperature, Token-Limit für die Antwort, Guardrails und Anwendungsfall pro Testfall | funktioniert |
| Prüfungen: `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`, `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens`, `refusal` | funktioniert |
| Guided Generation aus einer Teilmenge von JSON Schema, Schemavalidierung, Prüfungen über JSON-Pfade | funktioniert |
| Wiederholungen mit geforderter Erfolgsquote und Übereinstimmung zwischen den Durchläufen | funktioniert |
| `record`-Snapshots pro Betriebssystem-Build; `run --baseline` und `diff` mit verschlechterten, geänderten, verbesserten, hinzugefügten und entfernten Testfällen und Latenzgrenzen | funktioniert |
| `run --replay`: aufgezeichnete Antworten ohne Modell erneut prüfen | funktioniert |
| Ausgabe als Terminal-Text, Markdown, JUnit XML und JSON; Exit-Codes 0, 1, 2 | funktioniert |
| Bibliothek FMDriftKit mit DocC-Dokumentation | funktioniert |
| Eine Suite auf Private Cloud Compute oder einem anderen `LanguageModel`-Provider ausführen | geplant (0.2) |
| Testfälle mit Tool-Calling | geplant (0.3) |

## fmdrift und Apples Evaluations Framework

Xcode 27 hat Apples [Evaluations Framework](https://developer.apple.com/documentation/evaluations)
hinzugefügt (macOS 27 und neuer): in Swift geschriebene Evaluierungen innerhalb eines Test-Targets, mit Modell-Bewertern,
Tool-Call-Evaluatoren und Berichten in Xcode. Nutze es, wenn deine Prüfungen Swift-Code oder ein
Bewertungsmodell brauchen. fmdrift ist für die andere Seite derselben Aufgabe:

- Die Suite ist eine YAML-Datei, die auch Leute lesen und bearbeiten können, die kein Swift schreiben.
- Die Ergebnisse sind einfache JSON-Dateien in Git, eine pro Betriebssystem-Build, die sich in jedem
  CI-System über die Kommandozeile vergleichen lassen.
- Das Paket lässt sich für macOS 26 bauen, wo das Evaluations Framework nicht verfügbar ist, sodass
  auch die Antworten des früheren Modells aufgezeichnet werden können (Live-Läufe wurden in diesem Release
  nur unter macOS 27.0.1 geprüft).

## Installation

| Methode | Befehl |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| Release-Binary | Lade `fmdrift-<version>-macos-arm64.tar.gz` von [Releases](https://github.com/muhittincamdali/fmdrift/releases) herunter, prüfe es mit `SHA256SUMS` und lege `fmdrift` in deinen `PATH` |
| Aus dem Quellcode | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release` (das Binary ist `.build/release/fmdrift`) |
| Swift-Paket | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`, Produkt `FMDriftKit` |

## Verwendung

### Testfälle schreiben

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

Jeder Schlüssel samt seinen Grenzen steht in der [Referenz zum Suite-Format](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat).
`fmdrift validate` prüft eine Suite ohne Modell und nennt zu einem unbekannten Schlüssel den, den du
wahrscheinlich gemeint hast.

### Betriebssystem-Builds vergleichen

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

Ein Testfall, der früher bestanden hat und jetzt fehlschlägt, ist **verschlechtert** (`regressed`) und lässt den Lauf fehlschlagen (Exit-Status 1).
`--fail-on changed` schlägt auch bei Antworten fehl, die sich geändert haben, aber weiter bestehen, und
`--max-latency-increase 50%` bei Testfällen, die langsamer geworden sind. Wenn sich zwischen den beiden Läufen Prompt, Anweisungen, Optionen oder
Schema geändert haben, weist der Bericht darauf hin, damit ein bearbeiteter Prompt nicht mit
einem neuen Modell verwechselt wird.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="fmdrift run --baseline nach dem Kürzen der Anweisungen: Die Ticket-Zusammenfassung hat ihren Wortlaut geändert, und die themenfremde Anfrage, die das Modell früher mit Text abgelehnt hat, löst jetzt guardrailViolation aus und wird als verschlechtert gemeldet"></picture>

<sub>Ein echter Lauf unter macOS 27.0.1 (26A434): Die Anweisungen des Beispiels wurden auf "Answer in
at most eight words." gekürzt und mit dem committeten Snapshot verglichen. Die themenfremde Anfrage, die das
Modell zuvor mit dem Text "Unable to work with that request." abgelehnt hatte, löste jetzt
<code>guardrailViolation</code> aus. Für dieses Release stand nur ein Betriebssystem-Build zur Verfügung, deshalb ändert diese Demo
den Prompt statt des Betriebssystems; der Bericht ist derselbe.</sub>

### Aufgezeichnete Antworten ohne Modell prüfen

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay führt die Prüfungen der aktuellen Suite auf den Antworten in einem Snapshot aus. Es funktioniert auf jedem Mac,
auch auf CI-Runnern ohne Apple Intelligence, und findet eine Prüfung, die nicht mehr zu dem passt, was
das Modell gesagt hat. Ein Testfall, dessen Prompt sich seit der Aufzeichnung geändert hat, wird markiert.

### Berichte für CI

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| Exit-Status | Bedeutung |
| --- | --- |
| 0 | Jeder Testfall hat bestanden und nichts hat sich verschlechtert |
| 1 | Ein Testfall ist fehlgeschlagen oder hat sich verschlechtert (`validate`: eine Suite ist ungültig; `doctor`: kein Modell) |
| 2 | Falsche Argumente, eine nicht lesbare Suite oder ein nicht lesbarer Snapshot, oder kein Modell zum Ausführen |

`--allow-unavailable` macht aus einem fehlenden Modell einen Hinweis und Status 0, für Runner ohne Apple
Intelligence. [fmdrift in CI](docs/guides/fmdrift-in-ci.md) enthält einen vollständigen GitHub-Actions-Workflow.

## Wie es getestet wird

- **Mit dem echten Modell.** [Examples/support-app](Examples/support-app) wurde unter macOS
  27.0.1 (26A434), Mac17,6 (Apple M5 Max) aufgezeichnet: 15 Generierungen, alle bestanden, 9.70 s für den gesamten Lauf,
  Mediane zwischen 374 ms und 826 ms pro Antwort. Ein Test spielt diesen Snapshot bei jedem CI-Lauf über die
  Kommandozeile ab. Zwei weitere Tests fordern vom echten Modell eine einfache und eine strukturierte Antwort an,
  wenn `FMDRIFT_LIVE=1` gesetzt ist.
- **Was das echte Modell die Tests gelehrt hat.** Zehn Greedy-Läufe des Triage-Prompts lieferten
  dieselben Werte in vier verschiedenen Schlüsselreihenfolgen, deshalb werden strukturierte Antworten nach Wert verglichen. Die
  themenfremde Anfrage wurde mit Text abgelehnt, nicht mit einem Fehler, wie es Apples
  [Sicherheitsartikel](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)
  warnt, und mit kürzeren Anweisungen löste dieselbe Anfrage `guardrailViolation` aus.
- **Jedes Berichtsformat** wird Byte für Byte mit den Dateien in
  [Fixtures/expected](Fixtures/expected) verglichen, erzeugt aus einer festen Baseline und einem aktuellen Lauf, die jede
  Art von Ergebnis abdecken.
- **Nicht vertrauenswürdiger Text.** Die Modellausgabe kann Terminal-Escape-Sequenzen, bidirektionale Überschreibungen oder
  Markup enthalten; die Tests schleusen OSC 52, Bildschirmlöschen, eine Rechts-nach-links-Überschreibung, HTML und NUL durch
  die Terminal-, Markdown- und JUnit-Berichte. Die Leser für Suites und Snapshots weisen übergroße Dateien,
  tiefe Verschachtelung und YAML-Alias-Bomben zurück.
- **Jeder Befehl im selben Prozess**, gegen ein geskriptetes Modell mit gewähltem Betriebssystem-Build, einschließlich
  Aufzeichnen mit einem Build, Ausführen mit einem anderen, Diff-Richtlinien, Replay, einem fehlenden Modell und
  nicht lesbaren Dateien.

122 Tests. Alle bestehen auf einem Mac (Apple silicon) mit macOS 27.0.1 und Xcode 27.1; der
CI-Workflow führt sie mit Xcode 26.6 und Xcode 27 aus.

## Grenzen

- Live-Läufe brauchen einen Mac mit Apple Silicon und eingeschaltetem Apple Intelligence. Von GitHub gehostete macOS-Runner
  sind virtuelle Maschinen ohne beides; dort kann fmdrift validieren, per Replay prüfen und Diffs erstellen.
- Das Modell auf einem Mac und auf einem iPhone mit derselben Betriebssystemversion antwortet möglicherweise nicht gleich.
  fmdrift läuft nur unter macOS und versieht jeden Snapshot mit dem Mac und dem Betriebssystem, von dem er stammt.
- `refusal: true` besteht bei einem `guardrailViolation`- oder `refusal`-Fehler. Eine als Text geschriebene Ablehnung
  („Tut mir leid, dabei kann ich nicht helfen“) ist eine gewöhnliche Antwort: Prüfe ihre Wörter mit `containsAny`.
  Apple weist darauf hin, dass sich eine Ablehnung als Text im Code nicht immer von einer Antwort unterscheiden lässt.
- Die Latenz schließt das Erstellen der Session ein; die erste Antwort eines Laufs kann langsamer sein, während das Modell
  geladen wird. Vergleiche die Latenz zwischen Snapshots desselben Macs.
- Die Zahl der Ausgabe-Tokens stammt unter macOS 27 aus der Antwort und unter macOS
  26.4 bis 26.x aus `tokenCount(for:)`; vor 26.4 wird `maxOutputTokens` übersprungen, und das wird angegeben.
- Apples [Artikel zum Kontextfenster](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
  nennt 4,096 Tokens; `contextSize` meldete unter macOS 27.0.1 (26A434) 8,192. `fmdrift doctor`
  gibt den Wert des jeweiligen Macs aus.

## Voraussetzungen

| Plattform | Minimum |
| --- | --- |
| macOS (validate, replay, diff) | 26.0 |
| macOS (Live-Läufe) | 26.0 auf Apple Silicon mit Apple Intelligence; geprüft unter 27.0.1 |
| Toolchain (Build aus dem Quellcode) | Swift 6.2, Xcode 26.4 oder neuer |

## Architektur

- `Sources/FMDriftKit`: `SuiteLoader` liest Suites in `Suite` und `TestCase`; `Evaluator` und
  `SchemaValidator` prüfen eine `Generation`; `Runner` fragt einen `ModelProvider`
  (`SystemModelProvider` für das Modell auf dem Gerät, `ReplayProvider` für Snapshots) und baut ein
  `RunResult`; `SnapshotStore` liest und schreibt es; `SnapshotDiff` vergleicht zwei davon; `Advice` ordnet
  Fehler der Dokumentation von Apple zu; `Reports/` erzeugt Text, Markdown, JUnit XML und JSON.
- `Sources/FMDriftCLI`: die Befehle und Exit-Codes; `Sources/fmdrift` startet sie nur.
- Jede Generierung verwendet eine neue `LanguageModelSession`, sodass kein Testfall das Transcript eines anderen sieht.
- Fehler werden nach dem Namen des Case klassifiziert, weil macOS 27 sie von `GenerationError` nach
  `LanguageModelError` verschoben hat; dasselbe Binary funktioniert mit beiden.

## Dokumentation

- [Anleitungen](docs/guides/): deine erste Suite schreiben, Drift nach einem Betriebssystem-Update finden, fmdrift in CI.
- [API und Suite-Format](https://muhittincamdali.github.io/fmdrift/) (DocC) für FMDriftKit.
- [Beispiele](Examples/): die Suite support-app mit ihrem Snapshot, ein Swift-Programm auf Basis von FMDriftKit,
  ein GitHub-Actions-Workflow.
- [Änderungsprotokoll](CHANGELOG.md).

## Quellen

Dokumentation und Sessions von Apple, auf denen das Verhalten und die Hinweise von fmdrift beruhen, gelesen am 28. Oktober 2026:

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/): die Betriebssystemversion als Modellsignal (15:07), etwa zwei Modell-Updates pro Jahr, durchgeführt in Beta-Versionen
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) und [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## Mitwirken

Am meisten hilft eine Suite, die ein falsches Urteil zeigt, zusammen mit dem Snapshot, der es erzeugt hat. Siehe
[CONTRIBUTING.md](CONTRIBUTING.md) für Build, Tests und aufgezeichnete Dateien und
[SECURITY.md](SECURITY.md), um eine Sicherheitslücke vertraulich zu melden.

## Lizenz

[MIT](LICENSE)
