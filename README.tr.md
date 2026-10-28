<!-- i18n-source: README.md@ac64b25b73193784abe7b1fbd7738ac6a9609362 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/banner-light.svg" alt="fmdrift: Snapshot and regression tests for prompts to Apple's on-device foundation model, compared across OS builds."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/fmdrift/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: macOS 26+"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/fmdrift/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-guides-tr-light.svg" alt="Rehberler"></picture></a>
<a href="https://github.com/muhittincamdali/fmdrift/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/fmdrift/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

Apple'ın cihaz üzerinde çalışan foundation modeli işletim sistemi güncellemeleriyle değişir ve Apple'ın
önerisi, prompt'larınızı eski ve yeni modelde deneyip çıktıları karşılaştırmanızdır ([Updating prompts
for new model
versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)).
fmdrift bunu komut satırından yapar: YAML bir suite'teki prompt'ları çalıştığı Mac'in modelinde
çalıştırır, her yanıtı denetler, sonuçları işletim sistemi build'i başına kaydeder ve bir sonraki
build'de hangi yanıtların değiştiğini ya da bozulduğunu gösterir. WWDC26'da çalışma zamanı için bir
model sürümü sorulduğunda Apple, "bugün pratik sinyal işletim sistemi sürümüdür" yanıtını verdi; bu
yüzden fmdrift de onu kaydeder ([Machine Learning & AI Group
Lab](https://developer.apple.com/videos/play/wwdc2026/8016/), 15:07).

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-run-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-run-light.svg"><img src="docs/media/demo-run-light.svg" alt="support-app örneğinde fmdrift run: beş senaryo, her biri üç kez çalıştırılmış, hepsi geçiyor; her senaryo için tutarlılık ve ortanca gecikme gösteriliyor"></picture>

<sub>Gerçek komuttan ve cihaz üzerindeki gerçek modelden kaydedildi (<code>node scripts/demo.mjs</code>);
<a href="Examples/support-app">Examples/support-app</a> üzerinde, macOS 27.0.1 (26A434), Mac17,6 (Apple
M5 Max).</sub>

## Öne çıkanlar

- **Prompt'lar ve denetimler tek dosyada.** YAML bir suite, her prompt'u talimatları, örnekleme
  ayarları, guardrail'leri ve kullanım amacıyla birlikte tutar; yanıtların geçmesi gereken
  denetimleri de içerir: metin, düzenli ifadeler, JSON değerleri, uzunluk, gecikme, çıktı token'ları
  ve modelin isteği reddedip reddetmediği.
- **Yapılandırılmış çıktı da desteklenir.** Bir senaryoya JSON Schema verin; fmdrift guided
  generation (`DynamicGenerationSchema`) ister, sonucu şemaya göre denetler ve değerleri yol
  (path) ile okur.
- **Tek bir şanslı yanıt değil, kararlılık.** Her senaryo yeni oturumlarda birkaç kez
  çalıştırılabilir; rapor kaç çalıştırmanın geçtiğini ve kaçının aynı yanıtı verdiğini gösterir.
- **İşletim sistemi build'i başına snapshot'lar.** `record`, her yanıtı, gecikmeyi ve token sayısını
  onu üreten işletim sistemi build'inin altında JSON olarak kaydeder. `run --baseline` ve `diff`,
  neyin gerilediğini, değiştiğini ya da düzeldiğini yanıtların kelime farkıyla birlikte gösterir.
- **Her hata için kaynağıyla bir çözüm önerisi.** Guardrail ihlalleri, retler, bağlam penceresi,
  diller, şema sorunları, gecikme ve gerilemelerin her biri, Apple'ın dokümantasyonuna bağlanan bir
  öneriyle gelir.
- **CI için tasarlandı.** Terminal, Markdown, JUnit XML ve JSON çıktısı ile çıkış kodları. Apple
  Intelligence olmayan runner'lar da suite'leri doğrulayabilir ve kaydedilmiş yanıtları yeniden
  denetleyebilir.

## Hızlı başlangıç

**1. Kurun** (macOS 26 veya üstü, [Homebrew](https://brew.sh) ile):

```sh
brew install muhittincamdali/tap/fmdrift
```

**2. Bir suite yazın.** `fmdrift init`, çalışan iki senaryoyla `fmdrift.yaml` dosyasını yazar;
bunları uygulamanızın gönderdiği prompt'larla değiştirin.

```sh
fmdrift init
```

**3. Çalıştırın ve kaydedin.** `fmdrift run`, her yanıtı bu Mac'in modelinde denetler. `fmdrift record`, bu işletim sistemi build'i için yanıtları `fmdrift-snapshots/` içine kaydeder; bu klasörü
commit'leyin. Bir sonraki işletim sistemi güncellemesinden sonra `fmdrift run --baseline fmdrift-snapshots` neyin değiştiğini gösterir.

```sh
fmdrift run
fmdrift record
```

`fmdrift doctor`, bu Mac'in modeli çalıştırıp çalıştıramayacağını ve hangi işletim sistemi build'ini
kaydedeceğini söyler. [İlk suite'inizi yazın](docs/guides/write-your-first-suite.md) rehberi bunu
adım adım anlatır.

## Bugün çalışanlar

| Özellik | Durum |
| --- | --- |
| Senaryo başına varsayılanlar, talimatlar, örnekleme, sıcaklık (temperature), yanıt token sınırı, guardrail'ler ve kullanım amacı içeren YAML veya JSON suite'ler | çalışıyor |
| Denetimler: `contains`, `containsAny`, `notContains`, `equals`, `oneOf`, `matches`, `notMatches`, `minLength`, `maxLength`, `atLeast`, `atMost`, `maxLatency`, `maxOutputTokens`, `refusal` | çalışıyor |
| JSON Schema alt kümesinden guided generation, şema doğrulama, JSON yoluyla denetimler | çalışıyor |
| Gerekli geçme oranıyla tekrarlar ve çalıştırmalar arası tutarlılık | çalışıyor |
| İşletim sistemi build'i başına `record` snapshot'ları; gerileyen, değişen, düzelen, eklenen ve kaldırılan senaryoları ve gecikme sınırlarını gösteren `run --baseline` ve `diff` | çalışıyor |
| `run --replay`: kaydedilmiş yanıtları model olmadan yeniden denetler | çalışıyor |
| Terminal, Markdown, JUnit XML ve JSON çıktısı; 0, 1, 2 çıkış kodları | çalışıyor |
| DocC dokümantasyonlu FMDriftKit kütüphanesi | çalışıyor |
| Bir suite'i Private Cloud Compute veya başka bir `LanguageModel` sağlayıcısında çalıştırma | planlanıyor (0.2) |
| Tool-calling senaryoları | planlanıyor (0.3) |

## fmdrift ve Apple'ın Evaluations framework'ü

Xcode 27, Apple'ın [Evaluations framework](https://developer.apple.com/documentation/evaluations)'ünü
getirdi (macOS 27 ve üstü): bir test target'ının içinde Swift ile yazılan değerlendirmeler; model
yargıçları, tool-call değerlendiricileri ve Xcode'da raporlar. Denetimleriniz Swift kodu ya da bir
yargıç modeli gerektiriyorsa onu kullanın. fmdrift aynı işin diğer tarafı içindir:

- suite, Swift yazmayan kişilerin de okuyup düzenleyebileceği bir YAML dosyasıdır,
- sonuçlar git'te duran düz JSON dosyalarıdır (işletim sistemi build'i başına bir tane) ve herhangi
  bir CI sisteminde komut satırından karşılaştırılır,
- paket, Evaluations framework'ünün bulunmadığı macOS 26 için de derlenir; böylece önceki modelin
  yanıtları da kaydedilebilir (bu sürümdeki canlı çalıştırmalar yalnızca macOS 27.0.1'de denetlendi).

## Kurulum

| Yöntem | Komut |
| --- | --- |
| Homebrew | `brew install muhittincamdali/tap/fmdrift` |
| Release binary | [Releases](https://github.com/muhittincamdali/fmdrift/releases) sayfasından `fmdrift-<version>-macos-arm64.tar.gz` dosyasını indirin, `SHA256SUMS` ile doğrulayın, `fmdrift`'i `PATH`'inize koyun |
| Kaynak koddan | `git clone https://github.com/muhittincamdali/fmdrift.git && cd fmdrift && swift build -c release` (binary `.build/release/fmdrift` olur) |
| Swift paketi | `.package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0")`, ürün `FMDriftKit` |

## Kullanım

### Senaryo yazma

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

Her anahtar, sınırlarıyla birlikte [suite biçimi başvurusunda](https://muhittincamdali.github.io/fmdrift/documentation/fmdriftkit/suiteformat)
yer alır. `fmdrift validate` bir suite'i model olmadan denetler ve bilinmeyen bir anahtarı, büyük
olasılıkla kastettiğiniz anahtarla birlikte bildirir.

### İşletim sistemi build'lerini karşılaştırma

```sh
fmdrift record                                  # on the current OS: fmdrift-snapshots/<suite>/macOS-26.4-25E246.json
# … update macOS, or install a beta …
fmdrift run --baseline fmdrift-snapshots        # compares with the newest snapshot of another build
fmdrift diff fmdrift-snapshots/support/macOS-26.4-25E246.json fmdrift-snapshots/support/macOS-27.0.1-26A434.json
```

Daha önce geçip şimdi başarısız olan bir senaryo **gerilemiş** (`regressed`) sayılır ve çalıştırmayı
başarısız kılar (çıkış kodu 1). `--fail-on changed` yanıtı değişen ama hâlâ geçen senaryolarda da,
`--max-latency-increase 50%` ise yavaşlayan senaryolarda da başarısız olur. İki çalıştırma arasında
prompt, talimatlar, seçenekler veya şema değiştiyse rapor bunu belirtir; böylece düzenlenmiş bir
prompt yeni bir model sanılmaz.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-drift-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-drift-light.svg"><img src="docs/media/demo-drift-light.svg" alt="Talimatlar kısaltıldıktan sonra fmdrift run --baseline: destek talebi özetinin ifadesi değişti; modelin eskiden metinle reddettiği konu dışı istek artık guardrailViolation fırlatıyor ve gerilemiş olarak raporlanıyor"></picture>

<sub>macOS 27.0.1 (26A434) üzerinde gerçek bir çalıştırma: örneğin talimatları "Answer in
at most eight words." olarak kısaltıldı ve commit'lenmiş snapshot ile karşılaştırıldı. Modelin
"Unable to work with that request." metniyle reddettiği konu dışı istek artık
<code>guardrailViolation</code> fırlattı. Bu sürüm için yalnızca tek bir işletim sistemi build'i
vardı; bu yüzden demo işletim sistemini değil prompt'u değiştiriyor. Rapor aynıdır.</sub>

### Kaydedilmiş yanıtları model olmadan denetleme

```sh
fmdrift run --replay fmdrift-snapshots
```

Replay, güncel suite'in denetimlerini bir snapshot'taki yanıtlar üzerinde çalıştırır. Apple
Intelligence olmayan CI runner'ları dahil her Mac'te çalışır ve artık modelin söylediğiyle
eşleşmeyen bir denetimi yakalar. Kayıttan sonra prompt'u değişen bir senaryo işaretlenir.

### CI için raporlar

```sh
fmdrift run --junit fmdrift-junit.xml --markdown "$GITHUB_STEP_SUMMARY"
fmdrift run --json | jq '.runs[].cases[] | select(.passed | not) | .id'
```

| Çıkış kodu | Anlamı |
| --- | --- |
| 0 | Her senaryo geçti ve hiçbir şey gerilemedi |
| 1 | Bir senaryo başarısız oldu ya da geriledi (`validate`: suite geçersiz; `doctor`: model yok) |
| 2 | Yanlış argümanlar, okunamayan bir suite veya snapshot, ya da çalıştırılacak model yok |

`--allow-unavailable`, eksik bir modeli not düşüp 0 koduyla geçilen bir duruma çevirir; Apple
Intelligence olmayan runner'lar içindir. [CI'da fmdrift](docs/guides/fmdrift-in-ci.md) rehberinde
eksiksiz bir GitHub Actions iş akışı vardır.

## Nasıl test edilir

- **Gerçek modelde.** [Examples/support-app](Examples/support-app), macOS 27.0.1 (26A434), Mac17,6
  (Apple M5 Max) üzerinde kaydedildi: 15 üretim, hepsi geçti, tüm çalıştırma 9.70 s sürdü, yanıt
  başına ortanca değerler 374 ms ile 826 ms arasındaydı. Bir test, her CI çalıştırmasında bu
  snapshot'ı komut satırı üzerinden yeniden oynatır. `FMDRIFT_LIVE=1` ayarlıyken iki test daha
  gerçek modelden düz ve yapılandırılmış bir yanıt ister.
- **Gerçek modelin testlere öğrettikleri.** Triage prompt'unun on greedy çalıştırması aynı
  değerleri dört farklı anahtar sırasıyla döndürdü; bu yüzden yapılandırılmış yanıtlar değer
  üzerinden karşılaştırılır. Konu dışı istek, Apple'ın [güvenlik
  makalesinin](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)
  uyardığı gibi hatayla değil metinle reddedildi; talimatlar kısaltılınca aynı istek
  `guardrailViolation` fırlattı.
- **Her rapor biçimi**, her sonuç türünü kapsayan sabit bir baseline ve güncel çalıştırmadan üretilip
  [Fixtures/expected](Fixtures/expected) içindeki dosyalarla bayt bayt karşılaştırılır.
- **Güvenilmeyen metin.** Model çıktısı terminal escape'leri, çift yönlü geçersiz kılmalar veya
  işaretleme taşıyabilir; testler OSC 52, ekran temizleme, sağdan sola geçersiz kılma, HTML ve NUL
  karakterini terminal, Markdown ve JUnit raporlarından geçirir. Suite ve snapshot okuyucuları aşırı
  büyük dosyaları, derin iç içe geçmeyi ve YAML alias bomba saldırılarını reddeder.
- **Her komut süreç içinde**, seçilmiş bir işletim sistemi build'ine sahip betiklenmiş bir modele
  karşı çalıştırılır: bir build'de kayıt, başka bir build'de çalıştırma, diff politikaları, replay,
  eksik model ve okunamayan dosyalar dahil.

107 test. Hepsi Mac (Apple silicon), macOS 27.0.1 ve Xcode 27.1 üzerinde geçiyor; CI iş akışı
onları Xcode 26.6 ve Xcode 27 ile çalıştırır.

## Sınırlar

- Canlı çalıştırmalar Apple silicon'lu ve Apple Intelligence açık bir Mac ister. GitHub'ın
  barındırdığı macOS runner'ları buna sahip olmayan sanal makinelerdir; orada fmdrift doğrulayabilir,
  replay çalıştırabilir ve diff alabilir.
- Aynı işletim sistemi sürümüne sahip bir Mac'teki ve bir iPhone'daki model aynı yanıtı vermeyebilir.
  fmdrift yalnızca macOS'ta çalışır ve her snapshot'ı geldiği Mac ve işletim sistemiyle etiketler.
- `refusal: true`, bir `guardrailViolation` veya `refusal` hatasında geçer. Metin olarak yazılmış bir
  ret ("Üzgünüm, buna yardımcı olamam") sıradan bir yanıttır: sözcüklerini `containsAny` ile denetleyin.
  Apple, metinle yapılan bir retin kodda her zaman yanıttan ayırt edilemeyebileceğini belirtir.
- Gecikme, oturumun oluşturulmasını da içerir; model yüklenirken bir çalıştırmanın ilk yanıtı daha
  yavaş olabilir. Gecikmeyi aynı Mac'ten alınmış snapshot'lar arasında karşılaştırın.
- Çıktı token sayıları macOS 27'de yanıttan, macOS 26.4 ile 26.x arasında `tokenCount(for:)`
  çağrısından gelir; 26.4'ten önce `maxOutputTokens` atlanır ve bunu söyler.
- Apple'ın [bağlam penceresi makalesi](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
  4,096 token verir; `contextSize` macOS 27.0.1'de (26A434) 8,192 bildirdi. `fmdrift doctor`, elinizdeki
  Mac'in değerini yazdırır.

## Gereksinimler

| Platform | En düşük sürüm |
| --- | --- |
| macOS (validate, replay, diff) | 26.0 |
| macOS (canlı çalıştırma) | Apple silicon ve Apple Intelligence ile 26.0; 27.0.1'de denetlendi |
| Araç zinciri (kaynaktan derleme) | Swift 6.2, Xcode 26.4 veya üstü |

## Mimari

- `Sources/FMDriftKit`: `SuiteLoader` suite'leri `Suite` ve `TestCase` olarak okur; `Evaluator` ve
  `SchemaValidator` tek bir `Generation`'ı denetler; `Runner` bir `ModelProvider`'a sorar
  (cihaz üzerindeki model için `SystemModelProvider`, snapshot'lar için `ReplayProvider`) ve bir
  `RunResult` oluşturur; `SnapshotStore` onu okur ve yazar; `SnapshotDiff` iki tanesini karşılaştırır;
  `Advice` hataları Apple'ın dokümantasyonuyla eşler; `Reports/` metin, Markdown, JUnit XML ve JSON
  üretir.
- `Sources/FMDriftCLI`: komutlar ve çıkış kodları; `Sources/fmdrift` yalnızca onları başlatır.
- Her üretim yeni bir `LanguageModelSession` kullanır; böylece hiçbir senaryo bir başkasının
  transcript'ini görmez.
- Hatalar durum adına göre sınıflandırılır, çünkü macOS 27 onları `GenerationError`'dan
  `LanguageModelError`'a taşıdı; aynı binary ikisinde de çalışır.

## Dokümantasyon

- [Rehberler](docs/guides/): ilk suite'inizi yazma, işletim sistemi güncellemesinden sonra drift'i yakalama, CI'da fmdrift.
- FMDriftKit için [API ve suite biçimi](https://muhittincamdali.github.io/fmdrift/) (DocC).
- [Örnekler](Examples/): snapshot'ıyla birlikte support-app suite'i, FMDriftKit kullanan bir Swift programı,
  bir GitHub Actions iş akışı.
- [Değişiklik günlüğü](CHANGELOG.md).

## Kaynaklar

fmdrift'in davranışının ve önerilerinin dayandığı Apple dokümanları ve oturumları, 28 Ekim 2026'da okundu:

- [Updating prompts for new model versions](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions)
- [Evaluating prompts to measure performance and improve model responses](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
- [Machine Learning & AI Group Lab, WWDC26](https://developer.apple.com/videos/play/wwdc2026/8016/): model sinyali olarak işletim sistemi sürümü (15:07), yılda yaklaşık iki model güncellemesi, beta sürümlerinde yapılır
- [Prompting an on-device foundation model](https://developer.apple.com/documentation/foundationmodels/prompting-an-on-device-foundation-model)
- [Generating Swift data structures with guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output) ve [permissiveContentTransformations](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/guardrails/permissivecontenttransformations)
- [Managing the context window](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window)
- [Supporting languages and locales with Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models)
- [Analyzing the runtime performance of your Foundation Models app](https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app)
- [SystemLanguageModel.Availability](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum)
- [Evaluations](https://developer.apple.com/documentation/evaluations)

## Katkıda bulunma

En çok yardımı, yanlış bir karar gösteren bir suite ve onu üreten snapshot sağlar. Derleme, testler ve
kaydedilmiş dosyalar için [CONTRIBUTING.md](CONTRIBUTING.md), bir güvenlik açığını gizli olarak
bildirmek için [SECURITY.md](SECURITY.md) dosyasına bakın.

## Lisans

[MIT](LICENSE)
