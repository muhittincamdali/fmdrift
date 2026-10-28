<!-- i18n-source: README.md@ac64b25b73193784abe7b1fbd7738ac6a9609362 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-fr-light.svg" alt="Guides"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

Le foundation model qu’Apple exécute sur l’appareil change avec les mises à jour du système, et Apple conseille de tester vos
prompts sur l’ancien et sur le nouveau modèle et de comparer les résultats ([Updating prompts for new model
versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)).
fmdrift le fait depuis la ligne de commande : il exécute les prompts d’une suite YAML sur le modèle du
Mac sur lequel il tourne, vérifie chaque réponse, enregistre les résultats par build du système et montre quelles réponses
ont changé ou cassé au build suivant. Interrogée à la WWDC26 sur une version du modèle disponible à l’exécution, Apple a répondu
que « le signal pratique aujourd’hui est la version du système », et c’est donc ce que fmdrift enregistre
([Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/), 15:07).

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="fmdrift run sur l’exemple support-app : cinq cas, trois exécutions chacun, tous réussis, avec la concordance et la latence médiane de chaque cas"></picture>

<sub>Enregistré avec la vraie commande et le vrai modèle sur l’appareil (<code>node scripts/demo.mjs</code>)
sur <a href="Examples/support-app">Examples/support-app</a>, macOS 27.0.1 (26A434), Mac17,6 (Apple
M5 Max).</sub>

## Points forts

- **Les prompts et les vérifications dans un seul fichier.** Une suite YAML contient chaque prompt avec ses instructions,
  son échantillonnage, ses guardrails et son cas d’usage, ainsi que les vérifications que ses réponses doivent passer : texte, expressions
  régulières, valeurs JSON, longueur, latence, tokens de sortie, et si le modèle refuse.
- **La sortie structurée aussi.** Donnez un JSON Schema à un cas et fmdrift demande de la guided generation
  (`DynamicGenerationSchema`), vérifie le résultat par rapport au schéma et lit les valeurs par chemin.
- **De la stabilité, pas une seule réponse chanceuse.** Chaque cas peut s’exécuter plusieurs fois dans de nouvelles sessions ;
  le rapport indique combien d’exécutions ont réussi et combien ont donné la même réponse.
- **Des snapshots par build du système.** `record` enregistre chaque réponse, sa latence et son nombre de tokens en JSON sous
  le build du système qui l’a produite. `run --baseline` et `diff` montrent ce qui a régressé, changé ou été corrigé,
  avec un diff mot à mot des réponses.
- **Une solution pour chaque échec, avec sa source.** Les violations de guardrails, les refus, la fenêtre de contexte, les
  langues, les problèmes de schéma, la latence et les régressions s’accompagnent chacun d’une suggestion liée à
  la documentation d’Apple.
- **Conçu pour la CI.** Sortie en terminal, Markdown, JUnit XML et JSON, et codes de sortie. Les runners sans
  Apple Intelligence peuvent tout de même valider des suites et revérifier les réponses enregistrées.

## Démarrage rapide

**1. Installez** (macOS 26 ou version ultérieure, avec [Homebrew](https://brew.sh)) :

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. Écrivez une suite.** `fmdrift init` écrit `fmdrift.yaml` avec deux cas qui fonctionnent ; remplacez-les
par les prompts que votre app envoie.

```sh
fmdrift init
```

**3. Exécutez-la, puis enregistrez-la.** `fmdrift run` vérifie chaque réponse sur le modèle de ce Mac. `fmdrift record` enregistre les réponses de ce build du système dans `fmdrift-snapshots/` ; commitez ce dossier. Après la
prochaine mise à jour du système, `fmdrift run --baseline fmdrift-snapshots` montre ce qui a changé.

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor` indique si ce Mac peut exécuter le modèle et quel build du système il enregistrerait.
[Écrire votre première suite](docs/guides/write-your-first-suite.md) détaille chaque étape.

## Ce qui fonctionne aujourd’hui

| Fonctionnalité | État |
| --- | --- |
| Suites YAML ou JSON avec valeurs par défaut, instructions, échantillonnage, temperature, limite de tokens de réponse, guardrails et cas d’usage par cas | fonctionne |
| Vérifications : `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`, `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens`, `refusal` | fonctionne |
| Guided generation à partir d’un sous-ensemble de JSON Schema, validation de schéma, vérifications par chemin JSON | fonctionne |
| Répétitions avec un taux de réussite exigé, et concordance entre les exécutions | fonctionne |
| Snapshots `record` par build du système ; `run --baseline` et `diff` avec les cas en régression, modifiés, corrigés, ajoutés et supprimés, et des limites de latence | fonctionne |
| `run --replay` : revérifier les réponses enregistrées sans modèle | fonctionne |
| Sortie en terminal, Markdown, JUnit XML et JSON ; codes de sortie 0, 1, 2 | fonctionne |
| Bibliothèque FMDriftKit avec documentation DocC | fonctionne |
| Exécuter une suite sur Private Cloud Compute ou un autre fournisseur `LanguageModel` | prévu (0.2) |
| Cas avec tool-calling | prévu (0.3) |

## fmdrift et l’Evaluations framework d’Apple

Xcode 27 a ajouté l’[Evaluations framework](https://developer.apple.com/documentation/evaluations)
d’Apple (macOS 27 et versions ultérieures) : des évaluations écrites en Swift dans une cible de test, avec des modèles juges,
des évaluateurs de tool-calls et des rapports dans Xcode. Utilisez-le lorsque vos vérifications ont besoin de code Swift ou d’un
modèle juge. fmdrift s’adresse à l’autre versant du même travail :

- la suite est un fichier YAML que les personnes qui n’écrivent pas de Swift peuvent lire et modifier,
- les résultats sont de simples fichiers JSON dans git, un par build du système, comparés depuis la ligne de commande dans n’importe quel
  système de CI,
- le paquet se compile pour macOS 26, où l’Evaluations framework n’est pas disponible, de sorte que les
  réponses du modèle précédent peuvent aussi être enregistrées (les exécutions réelles de cette version n’ont été vérifiées
  que sur macOS 27.0.1).

## Installation

| Méthode | Commande |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| Binaire de la version | Téléchargez `fmdrift-<version>-macos-arm64.tar.gz` depuis [Releases](https://github.com/muhittincamdali/fmdrift/releases), vérifiez-le avec `SHA256SUMS`, puis placez `fmdrift` dans votre `PATH` |
| Depuis les sources | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release` (le binaire est `.build/release/fmdrift`) |
| Paquet Swift | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`, produit `FMDriftKit` |

## Utilisation

### Écrire des cas

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

Chaque clé, avec ses limites, figure dans la [référence du format de suite](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat).
`fmdrift validate` vérifie une suite sans modèle et, pour une clé inconnue, nomme celle que vous
vouliez probablement écrire.

### Comparer des builds du système

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

Un cas qui réussissait avant et échoue maintenant est en **régression** (`regressed`) et fait échouer l’exécution (code de sortie 1).
`--fail-on changed` fait aussi échouer sur les réponses qui ont changé tout en réussissant encore, et
`--max-latency-increase 50%` sur les cas devenus plus lents. Lorsque le prompt, les instructions, les options ou
le schéma ont changé entre les deux exécutions, le rapport le signale, afin qu’un prompt modifié ne soit pas pris pour
un nouveau modèle.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="fmdrift run --baseline après avoir raccourci les instructions : le résumé du ticket a changé de formulation, et la demande hors sujet que le modèle refusait auparavant par du texte déclenche maintenant guardrailViolation et est signalée comme régression"></picture>

<sub>Une exécution réelle sur macOS 27.0.1 (26A434) : les instructions de l’exemple ont été raccourcies en "Answer in
at most eight words." puis comparées au snapshot commité. La demande hors sujet que le
modèle avait refusée avec le texte "Unable to work with that request." a maintenant déclenché
<code>guardrailViolation</code>. Un seul build du système était disponible pour cette version ; cette démo
change donc le prompt au lieu du système. Le rapport est le même.</sub>

### Vérifier des réponses enregistrées sans modèle

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay exécute les vérifications de la suite actuelle sur les réponses d’un snapshot. Il fonctionne sur n’importe quel Mac,
y compris les runners de CI sans Apple Intelligence, et repère une vérification qui ne correspond plus à
ce que le modèle a dit. Un cas dont le prompt a changé depuis l’enregistrement est signalé.

### Rapports pour la CI

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| Code de sortie | Signification |
| --- | --- |
| 0 | Tous les cas ont réussi et rien n’a régressé |
| 1 | Un cas a échoué ou régressé (`validate` : une suite est invalide ; `doctor` : pas de modèle) |
| 2 | Arguments incorrects, suite ou snapshot illisible, ou pas de modèle sur lequel exécuter |

`--allow-unavailable` transforme l’absence de modèle en simple note avec le code 0, pour les runners sans Apple
Intelligence. [fmdrift dans la CI](docs/guides/fmdrift-in-ci.md) fournit un workflow GitHub Actions complet.

## Comment c’est testé

- **Sur le vrai modèle.** [Examples/support-app](Examples/support-app) a été enregistré sur macOS
  27.0.1 (26A434), Mac17,6 (Apple M5 Max) : 15 générations, toutes réussies, 9.70 s pour toute l’exécution,
  avec des médianes comprises entre 374 ms et 826 ms par réponse. Un test rejoue ce snapshot via la ligne de
  commande à chaque exécution de la CI. Deux autres tests demandent au vrai modèle une réponse simple et une réponse structurée
  lorsque `FMDRIFT_LIVE=1` est défini.
- **Ce que le vrai modèle a appris aux tests.** Dix exécutions greedy du prompt de triage ont renvoyé les
  mêmes valeurs dans quatre ordres de clés différents, donc les réponses structurées sont comparées par valeur. La
  demande hors sujet a été refusée par du texte, pas par une erreur, comme le
  [mentionne l’article sur la sécurité](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)
  d’Apple, et avec des instructions plus courtes, la même demande a déclenché `guardrailViolation`.
- **Chaque format de rapport** est comparé octet par octet aux fichiers de
  [Fixtures/expected](Fixtures/expected), à partir d’une baseline fixe et d’une exécution actuelle qui couvrent chaque
  type de résultat.
- **Texte non fiable.** La sortie du modèle peut contenir des séquences d’échappement de terminal, des remplacements bidirectionnels ou
  du balisage ; les tests font passer OSC 52, l’effacement d’écran, un remplacement de droite à gauche, du HTML et NUL à travers
  les rapports de terminal, Markdown et JUnit. Les lecteurs de suites et de snapshots refusent les fichiers trop volumineux,
  l’imbrication profonde et les bombes d’alias YAML.
- **Chaque commande dans le même processus**, face à un modèle simulé avec un build du système choisi, y compris
  l’enregistrement sur un build, l’exécution sur un autre, les politiques de diff, replay, l’absence de modèle et
  les fichiers illisibles.

107 tests. Tous passent sur un Mac (Apple silicon) sous macOS 27.0.1 avec Xcode 27.1 ; le workflow
de CI les exécute avec Xcode 26.6 et Xcode 27.

## Limites

- Les exécutions réelles demandent un Mac avec Apple silicon et Apple Intelligence activé. Les runners macOS hébergés par GitHub
  sont des machines virtuelles qui n’en disposent pas ; là, fmdrift peut valider, rejouer avec replay et comparer avec diff.
- Le modèle d’un Mac et celui d’un iPhone avec la même version du système peuvent ne pas répondre de la même façon.
  fmdrift ne fonctionne que sous macOS et étiquette chaque snapshot avec le Mac et le système dont il provient.
- `refusal: true` réussit sur une erreur `guardrailViolation` ou `refusal`. Un refus écrit sous forme de texte
  (« Désolé, je ne peux pas vous aider ») est une réponse ordinaire : vérifiez ses mots avec `containsAny`.
  Apple note qu’un refus en texte ne peut pas toujours être distingué d’une réponse dans le code.
- La latence inclut la création de la session ; la première réponse d’une exécution peut être plus lente pendant que le modèle
  se charge. Comparez la latence entre des snapshots du même Mac.
- Le nombre de tokens de sortie provient de la réponse sur macOS 27 et de `tokenCount(for:)` sur macOS
  26.4 à 26.x ; avant 26.4, `maxOutputTokens` est ignoré et le signale.
- L’[article sur la fenêtre de contexte](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
  d’Apple indique 4,096 tokens ; `contextSize` a renvoyé 8,192 sur macOS 27.0.1 (26A434). `fmdrift doctor`
  affiche la valeur du Mac que vous utilisez.

## Prérequis

| Plateforme | Minimum |
| --- | --- |
| macOS (validate, replay, diff) | 26.0 |
| macOS (exécutions réelles) | 26.0 sur Apple silicon avec Apple Intelligence ; vérifié sur 27.0.1 |
| Chaîne d’outils (compilation depuis les sources) | Swift 6.2, Xcode 26.4 ou version ultérieure |

## Architecture

- `Sources/FMDriftKit` : `SuiteLoader` lit les suites dans `Suite` et `TestCase` ; `Evaluator` et
  `SchemaValidator` vérifient une `Generation` ; `Runner` interroge un `ModelProvider`
  (`SystemModelProvider` pour le modèle sur l’appareil, `ReplayProvider` pour les snapshots) et construit un
  `RunResult` ; `SnapshotStore` le lit et l’écrit ; `SnapshotDiff` en compare deux ; `Advice` associe
  les échecs à la documentation d’Apple ; `Reports/` produit du texte, du Markdown, du JUnit XML et du JSON.
- `Sources/FMDriftCLI` : les commandes et les codes de sortie ; `Sources/fmdrift` ne fait que les démarrer.
- Chaque génération utilise une nouvelle `LanguageModelSession`, de sorte qu’aucun cas ne voit le transcript d’un autre.
- Les erreurs sont classées par nom de case, car macOS 27 les a déplacées de `GenerationError` vers
  `LanguageModelError` ; le même binaire fonctionne sur les deux.

## Documentation

- [Guides](docs/guides/) : écrire votre première suite, repérer le drift après une mise à jour du système, fmdrift dans la CI.
- [API et format de suite](https://muhittincamdali.github.io/fmdrift/) (DocC) pour FMDriftKit.
- [Exemples](Examples/) : la suite support-app avec son snapshot, un programme Swift reposant sur FMDriftKit,
  un workflow GitHub Actions.
- [Journal des modifications](CHANGELOG.md).

## Sources

Documentation et sessions d’Apple sur lesquelles reposent le comportement et les conseils de fmdrift, consultées le 28 octobre 2026 :

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/) : la version du système comme signal du modèle (15:07), environ deux mises à jour du modèle par an, faites dans des versions bêta
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) et [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## Contribuer

Ce qui aide le plus, c’est une suite qui montre un verdict erroné, avec le snapshot qui l’a produit. Consultez
[CONTRIBUTING.md](CONTRIBUTING.md) pour la compilation, les tests et les fichiers enregistrés, et
[SECURITY.md](SECURITY.md) pour signaler une vulnérabilité en privé.

## Licence

[MIT](LICENSE)
