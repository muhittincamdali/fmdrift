// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fmdrift",
    // Foundation Models ships with macOS 26; the on-device model needs Apple silicon and Apple
    // Intelligence turned on.
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "FMDriftKit", targets: ["FMDriftKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams", from: "6.2.2")
    ],
    targets: [
        // Suite files, assertions, the runner, snapshots, diffs and reports.
        .target(name: "FMDriftKit", dependencies: ["Yams"]),
        .testTarget(name: "FMDriftKitTests", dependencies: ["FMDriftKit"]),
    ],
    swiftLanguageModes: [.v6]
)
