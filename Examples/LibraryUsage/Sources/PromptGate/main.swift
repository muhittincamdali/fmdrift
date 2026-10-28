import FMDriftKit
import Foundation

// PromptGate runs one suite from Swift code and applies its own rule: every case must pass and
// no case may answer differently from the snapshot. Pass a snapshot to check its recorded
// answers instead of asking the model, which works on any Mac.
//
//   swift run PromptGate <suite.yaml> [<snapshot.json>]

let arguments = CommandLine.arguments.dropFirst()
guard let suitePath = arguments.first else {
    print("usage: PromptGate <suite.yaml> [<snapshot.json>]")
    exit(2)
}

do {
    let suite = try SuiteLoader.load(contentsOf: URL(fileURLWithPath: suitePath))
    let provider: any ModelProvider
    var baseline: RunResult?
    if let snapshotPath = arguments.dropFirst().first {
        let snapshot = try SnapshotStore.read(contentsOf: URL(fileURLWithPath: snapshotPath))
        provider = ReplayProvider(snapshot: snapshot)
        baseline = snapshot
    } else {
        provider = SystemModelProvider()
        guard await provider.availability() == .available else {
            print("The on-device model is not available on this Mac.")
            exit(2)
        }
    }

    let replay = provider as? ReplayProvider
    let result = await Runner(provider: provider).run(
        suite,
        sampleCount: { testCase in replay?.recordedCount(for: testCase.id) ?? testCase.repeatCount }
    )
    for testCase in result.cases {
        let verdict = testCase.passed ? "pass" : "FAIL"
        print("\(verdict)  \(testCase.id)  \(testCase.passCount)/\(testCase.samples.count)")
    }

    var changed: [String] = []
    if let baseline {
        let diff = SnapshotDiff(baseline: baseline, current: result)
        changed = diff.cases.filter { $0.status != .unchanged }.map(\.id)
    }
    if !changed.isEmpty {
        print("Answers changed: \(changed.joined(separator: ", "))")
    }
    exit(result.passed && changed.isEmpty ? 0 : 1)
} catch let error as SuiteError {
    print(error.description)
    exit(2)
} catch let error as SnapshotError {
    print(error.description)
    exit(2)
}
