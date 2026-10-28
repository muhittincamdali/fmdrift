<!-- i18n-source: README.md@9a56eea1e1d6d7b348e0f274964a3c1a0efb9b49 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-es-light.svg" alt="Guías"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

El foundation model que Apple ejecuta en el dispositivo cambia con las actualizaciones del sistema operativo, y Apple aconseja probar tus
prompts con el modelo antiguo y con el nuevo y comparar la salida ([Updating prompts for new model
versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)).
fmdrift lo hace desde la línea de comandos: ejecuta los prompts de una suite YAML con el modelo del
Mac en el que se ejecuta, comprueba cada respuesta, guarda los resultados por build del sistema operativo y muestra qué respuestas
cambiaron o se rompieron en la siguiente build. Cuando se le preguntó en la WWDC26 por una versión del modelo en tiempo de ejecución, Apple respondió
que «la señal práctica hoy es la versión del sistema operativo», y eso es lo que registra fmdrift
([Machine Learning & AI Group Lab](https://developer.apple.com/videos/play/wwdc2026/8016/), 15:07).

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="fmdrift run sobre el ejemplo support-app: cinco casos, tres ejecuciones cada uno, todos correctos, con la coincidencia y la latencia mediana de cada caso"></picture>

<sub>Grabado con el comando real y el modelo real del dispositivo (<code>node scripts/demo.mjs</code>)
sobre <a href="Examples/support-app">Examples/support-app</a>, en macOS 27.0.1 (26A434), Mac17,6 (Apple
M5 Max).</sub>

## Lo más destacado

- **Prompts y comprobaciones en un solo archivo.** Una suite YAML contiene cada prompt con sus instrucciones,
  muestreo, guardrails y caso de uso, y las comprobaciones que deben superar sus respuestas: texto, expresiones
  regulares, valores JSON, longitud, latencia, tokens de salida y si el modelo rechaza la petición.
- **También salida estructurada.** Dale a un caso un JSON Schema y fmdrift pide guided generation
  (`DynamicGenerationSchema`), comprueba el resultado con el esquema y lee los valores por ruta.
- **Estabilidad, no una respuesta afortunada.** Cada caso puede ejecutarse varias veces en sesiones nuevas;
  el informe muestra cuántas ejecuciones pasaron y cuántas dieron la misma respuesta.
- **Snapshots por build del sistema operativo.** `record` guarda cada respuesta, latencia y número de tokens como JSON bajo
  la build del sistema operativo que la produjo. `run --baseline` y `diff` muestran qué ha empeorado, cambiado o mejorado,
  con un diff palabra por palabra de las respuestas.
- **Una solución para cada fallo, con su fuente.** Las infracciones de guardrails, los rechazos, la ventana de contexto, los
  idiomas, los problemas de esquema, la latencia y las regresiones traen cada uno una sugerencia enlazada a
  la documentación de Apple.
- **Pensado para CI.** Salida en terminal, Markdown, JUnit XML y JSON, y códigos de salida. Los runners sin
  Apple Intelligence también pueden validar suites y volver a comprobar respuestas guardadas.

## Inicio rápido

**1. Instala** (macOS 26 o posterior, con [Homebrew](https://brew.sh)):

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. Escribe una suite.** `fmdrift init` crea `fmdrift.yaml` con dos casos que funcionan; sustitúyelos
por los prompts que envía tu app.

```sh
fmdrift init
```

**3. Ejecútala y guárdala.** `fmdrift run` comprueba cada respuesta con el modelo de este Mac. `fmdrift record` guarda las respuestas de esta build del sistema operativo en `fmdrift-snapshots/`; haz commit de esa carpeta. Tras la
próxima actualización del sistema operativo, `fmdrift run --baseline fmdrift-snapshots` muestra qué ha cambiado.

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor` indica si este Mac puede ejecutar el modelo y qué build del sistema operativo registraría.
[Escribe tu primera suite](docs/guides/write-your-first-suite.md) lo recorre paso a paso.

## Qué funciona hoy

| Función | Estado |
| --- | --- |
| Suites YAML o JSON con valores por defecto, instrucciones, muestreo, temperature, límite de tokens de respuesta, guardrails y caso de uso por caso | funciona |
| Comprobaciones: `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`, `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens`, `refusal` | funciona |
| Guided generation a partir de un subconjunto de JSON Schema, validación de esquemas, comprobaciones por ruta JSON | funciona |
| Repeticiones con una tasa de aciertos exigida y coincidencia entre ejecuciones | funciona |
| Snapshots de `record` por build del sistema operativo; `run --baseline` y `diff` con casos que han empeorado, cambiado, mejorado, añadidos y eliminados, y límites de latencia | funciona |
| `run --replay`: volver a comprobar respuestas guardadas sin un modelo | funciona |
| Salida en terminal, Markdown, JUnit XML y JSON; códigos de salida 0, 1, 2 | funciona |
| Biblioteca FMDriftKit con documentación DocC | funciona |
| Ejecutar una suite en Private Cloud Compute o con otro proveedor de `LanguageModel` | planificado (0.2) |
| Casos con tool-calling | planificado (0.3) |

## fmdrift y el Evaluations framework de Apple

Xcode 27 añadió el [Evaluations framework](https://developer.apple.com/documentation/evaluations)
de Apple (macOS 27 y posterior): evaluaciones escritas en Swift dentro de un target de pruebas, con jueces basados en modelos,
evaluadores de tool-calls e informes en Xcode. Úsalo cuando tus comprobaciones necesiten código Swift o un modelo
juez. fmdrift es para la otra cara del mismo trabajo:

- la suite es un archivo YAML que pueden leer y editar las personas que no escriben Swift,
- los resultados son archivos JSON simples en git, uno por build del sistema operativo, que se comparan desde la línea de comandos en cualquier
  sistema de CI,
- el paquete se compila para macOS 26, donde el Evaluations framework no está disponible, de modo que
  también se pueden registrar las respuestas del modelo anterior (las ejecuciones en vivo de esta versión se comprobaron
  solo en macOS 27.0.1).

## Instalación

| Método | Comando |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| Binario de la versión | Descarga `fmdrift-<version>-macos-arm64.tar.gz` desde [Releases](https://github.com/muhittincamdali/fmdrift/releases), compruébalo con `SHA256SUMS` y pon `fmdrift` en tu `PATH` |
| Desde el código fuente | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release` (el binario es `.build/release/fmdrift`) |
| Paquete de Swift | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`, producto `FMDriftKit` |

## Uso

### Escribir casos

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

Cada clave, con sus límites, está en la [referencia del formato de suite](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat).
`fmdrift validate` comprueba una suite sin un modelo y, ante una clave desconocida, indica la que
probablemente querías escribir.

### Comparar builds del sistema operativo

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

Un caso que antes pasaba y ahora falla ha **empeorado** (`regressed`) y hace fallar la ejecución (estado de salida 1).
`--fail-on changed` también falla con las respuestas que cambiaron aunque sigan pasando, y
`--max-latency-increase 50%` con los casos que se volvieron más lentos. Cuando el prompt, las instrucciones, las opciones o
el esquema cambiaron entre las dos ejecuciones, el informe lo indica, de modo que un prompt editado no se confunde con
un modelo nuevo.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="fmdrift run --baseline tras acortar las instrucciones: el resumen del ticket cambió de redacción, y la petición fuera de tema que el modelo solía rechazar con texto ahora lanza guardrailViolation y se informa como empeoramiento"></picture>

<sub>Una ejecución real en macOS 27.0.1 (26A434): las instrucciones del ejemplo se acortaron a "Answer in
at most eight words." y se compararon con el snapshot del repositorio. La petición fuera de tema que el
modelo había rechazado con el texto "Unable to work with that request." ahora lanzó
<code>guardrailViolation</code>. Solo había una build del sistema operativo disponible para esta versión, así que esta demo
cambia el prompt en lugar del sistema operativo; el informe es el mismo.</sub>

### Comprobar respuestas guardadas sin un modelo

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay ejecuta las comprobaciones de la suite actual sobre las respuestas de un snapshot. Funciona en cualquier Mac,
incluidos los runners de CI sin Apple Intelligence, y detecta una comprobación que ya no coincide con
lo que dijo el modelo. Se marca el caso cuyo prompt cambió desde la grabación.

### Informes para CI

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| Estado de salida | Significado |
| --- | --- |
| 0 | Todos los casos pasaron y nada empeoró |
| 1 | Un caso falló o empeoró (`validate`: una suite no es válida; `doctor`: no hay modelo) |
| 2 | Argumentos incorrectos, una suite o un snapshot ilegibles, o no hay modelo con el que ejecutar |

`--allow-unavailable` convierte la falta de modelo en una nota y estado 0, para los runners sin Apple
Intelligence. [fmdrift en CI](docs/guides/fmdrift-in-ci.md) incluye un flujo de trabajo completo de GitHub Actions.

## Cómo se prueba

- **Con el modelo real.** [Examples/support-app](Examples/support-app) se grabó en macOS
  27.0.1 (26A434), Mac17,6 (Apple M5 Max): 15 generaciones, todas correctas, 9.70 s para toda la ejecución,
  con medianas de entre 374 ms y 826 ms por respuesta. Una prueba reproduce ese snapshot a través de la línea de
  comandos en cada ejecución de CI. Otras dos pruebas piden al modelo real una respuesta simple y otra estructurada
  cuando se define `FMDRIFT_LIVE=1`.
- **Lo que el modelo real enseñó a las pruebas.** Diez ejecuciones greedy del prompt de triaje devolvieron los
  mismos valores con cuatro órdenes de claves distintos, así que las respuestas estructuradas se comparan por valor. La
  petición fuera de tema se rechazó con texto, no con un error, como advierte el
  [artículo de seguridad](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)
  de Apple, y con instrucciones más cortas la misma petición lanzó `guardrailViolation`.
- **Todos los formatos de informe** se comparan byte a byte con los archivos de
  [Fixtures/expected](Fixtures/expected), a partir de un baseline fijo y una ejecución actual que cubren cada
  tipo de resultado.
- **Texto no confiable.** La salida del modelo puede contener secuencias de escape de terminal, anulaciones bidireccionales o
  marcado; las pruebas pasan OSC 52, borrado de pantalla, una anulación de derecha a izquierda, HTML y NUL por
  los informes de terminal, Markdown y JUnit. Los lectores de suites y snapshots rechazan archivos demasiado grandes,
  anidamiento profundo y bombas de alias de YAML.
- **Cada comando en proceso**, con un modelo guionizado y una build del sistema operativo elegida, incluidos
  grabar en una build, ejecutar en otra, políticas de diff, replay, la falta de modelo y
  archivos ilegibles.

112 pruebas. Todas pasan en un Mac (Apple silicon) con macOS 27.0.1 y Xcode 27.1; el flujo de CI
las ejecuta con Xcode 26.6 y Xcode 27.

## Límites

- Las ejecuciones en vivo necesitan un Mac con Apple silicon y Apple Intelligence activado. Los runners de macOS
  alojados en GitHub son máquinas virtuales que no lo tienen; allí fmdrift puede validar, reproducir con replay y hacer diff.
- El modelo de un Mac y el de un iPhone con la misma versión del sistema operativo pueden no responder igual.
  fmdrift solo se ejecuta en macOS y etiqueta cada snapshot con el Mac y el sistema operativo de los que procede.
- `refusal: true` pasa con un error `guardrailViolation` o `refusal`. Un rechazo escrito como texto
  («Lo siento, no puedo ayudarte con eso») es una respuesta normal: comprueba sus palabras con `containsAny`.
  Apple señala que no siempre se puede distinguir en el código un rechazo en texto de una respuesta.
- La latencia incluye la creación de la sesión; la primera respuesta de una ejecución puede tardar más mientras el modelo
  se carga. Compara la latencia entre snapshots del mismo Mac.
- El número de tokens de salida procede de la respuesta en macOS 27 y de `tokenCount(for:)` en macOS
  26.4 a 26.x; antes de la 26.4, `maxOutputTokens` se omite y lo indica.
- El [artículo sobre la ventana de contexto](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
  de Apple da 4,096 tokens; `contextSize` informó 8,192 en macOS 27.0.1 (26A434). `fmdrift doctor`
  muestra el valor del Mac que estés usando.

## Requisitos

| Plataforma | Versión mínima |
| --- | --- |
| macOS (validate, replay, diff) | 26.0 |
| macOS (ejecuciones en vivo) | 26.0 con Apple silicon y Apple Intelligence; comprobado en 27.0.1 |
| Herramientas (compilar desde el código fuente) | Swift 6.2, Xcode 26.4 o posterior |

## Arquitectura

- `Sources/FMDriftKit`: `SuiteLoader` lee las suites como `Suite` y `TestCase`; `Evaluator` y
  `SchemaValidator` comprueban una `Generation`; `Runner` consulta a un `ModelProvider`
  (`SystemModelProvider` para el modelo del dispositivo, `ReplayProvider` para los snapshots) y construye un
  `RunResult`; `SnapshotStore` lo lee y lo escribe; `SnapshotDiff` compara dos; `Advice` asigna
  los fallos a la documentación de Apple; `Reports/` genera texto, Markdown, JUnit XML y JSON.
- `Sources/FMDriftCLI`: los comandos y los códigos de salida; `Sources/fmdrift` solo los inicia.
- Cada generación usa una `LanguageModelSession` nueva, así que ningún caso ve el transcript de otro.
- Los errores se clasifican por el nombre del case porque macOS 27 los movió de `GenerationError` a
  `LanguageModelError`; el mismo binario funciona en ambos.

## Documentación

- [Guías](docs/guides/): escribir tu primera suite, detectar el drift tras una actualización del sistema operativo, fmdrift en CI.
- [API y formato de suite](https://muhittincamdali.github.io/fmdrift/) (DocC) de FMDriftKit.
- [Ejemplos](Examples/): la suite support-app con su snapshot, un programa en Swift que usa FMDriftKit,
  un flujo de trabajo de GitHub Actions.
- [Registro de cambios](CHANGELOG.md).

## Fuentes

Documentación y sesiones de Apple en las que se apoyan el comportamiento y los consejos de fmdrift, leídas el 28 de octubre de 2026:

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/): la versión del sistema operativo como señal del modelo (15:07), unas dos actualizaciones del modelo al año, hechas en versiones beta
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) y [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## Contribuir

Lo que más ayuda es una suite que muestre un veredicto erróneo, junto con el snapshot que lo produjo. Consulta
[CONTRIBUTING.md](CONTRIBUTING.md) para compilar, probar y los archivos grabados, y
[SECURITY.md](SECURITY.md) para informar de una vulnerabilidad de forma privada.

## Licencia

[MIT](LICENSE)
