// swift-tools-version: 6.2
import PackageDescription

// Uses FMDriftKit from this repository. In your own package, depend on
// .package(url: "https://github.com/muhittincamdali/fmdrift", from: "0.1.0") instead.
let package = Package(
    name: "PromptGate",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(name: "fmdrift", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "PromptGate",
            dependencies: [.product(name: "FMDriftKit", package: "fmdrift")]
        )
    ],
    swiftLanguageModes: [.v6]
)
