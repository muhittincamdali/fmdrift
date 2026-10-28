// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fmdrift",
    // Foundation Models ships with macOS 26; the on-device model needs Apple silicon and Apple
    // Intelligence turned on, which `fmdrift doctor` checks at run time.
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "FMDriftKit", targets: ["FMDriftKit"]),
        .executable(name: "fmdrift", targets: ["fmdrift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
        .package(url: "https://github.com/jpsim/Yams", from: "6.2.2"),
    ],
    targets: [
        // Suite files, assertions, the runner, snapshots, diffs and reports.
        .target(name: "FMDriftKit", dependencies: ["Yams"]),
        // The command-line interface as a library, so tests can run the commands in-process.
        .target(
            name: "FMDriftCLI",
            dependencies: [
                "FMDriftKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(name: "fmdrift", dependencies: ["FMDriftCLI"]),
        .testTarget(name: "FMDriftKitTests", dependencies: ["FMDriftKit"]),
        .testTarget(name: "FMDriftCLITests", dependencies: ["FMDriftCLI", "FMDriftKit"]),
    ],
    swiftLanguageModes: [.v6]
)
