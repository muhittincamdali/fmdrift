# Getting started

Run a suite from Swift, record it, and compare two snapshots.

## Add the package

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/fmdrift.git", from: "0.1.0")
],
targets: [
    .executableTarget(name: "PromptGate", dependencies: [
        .product(name: "FMDriftKit", package: "fmdrift")
    ])
]
```

FMDriftKit needs macOS 26 or later. Running prompts needs a Mac with Apple silicon and Apple
Intelligence turned on; reading suites, replaying snapshots and comparing them do not.

## Check that the model is available

```swift
let provider = SystemModelProvider(timeout: 60)
switch await provider.availability() {
case .available:
    break
case .unavailable(let reason, let explanation):
    print("No model (\(reason)): \(explanation)")
}
```

## Run a suite

```swift
let suite = try SuiteLoader.load(contentsOf: URL(fileURLWithPath: "fmdrift.yaml"))
let result = await Runner(provider: provider).run(suite, progress: { progress in
    print("\(progress.completed)/\(progress.total) \(progress.caseID)")
})
for testCase in result.cases where !testCase.passed {
    print(testCase.id, testCase.passCount, "of", testCase.samples.count)
}
```

``Runner`` sends one generation at a time, each in a new session, and checks it with
``Evaluator``. A case passes when its share of passing answers reaches its `minPassRate`.

## Record and compare

```swift
let directory = URL(fileURLWithPath: "fmdrift-snapshots")
let url = SnapshotStore.url(in: directory, suite: suite.name, environment: result.environment)
try SnapshotStore.write(result, to: url)

let baseline = try SnapshotStore.read(contentsOf: directory.appendingPathComponent("support/macOS-26.4-25E246.json"))
let diff = SnapshotDiff(baseline: baseline, current: result, latencyIncrease: 0.5)
print(TerminalReport.diff(diff, style: .detect()))
```

## Check recorded answers without a model

``ReplayProvider`` answers with the generations stored in a snapshot. Pass its recorded count
as the sample count so each recorded answer is checked once:

```swift
let replay = ReplayProvider(snapshot: baseline)
let rechecked = await Runner(provider: replay).run(suite, sampleCount: { replay.recordedCount(for: $0.id) })
```

The `Examples/LibraryUsage` package in the repository is a complete program built this way.
