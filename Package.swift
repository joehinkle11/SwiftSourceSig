// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftSourceSig",
    products: [
        .library(
            name: "SwiftSourceSig",
            targets: ["SwiftSourceSig"]
        ),
        .executable(
            name: "SwiftSourceSigLint",
            targets: ["SwiftSourceSigLint"]
        ),
        .plugin(
            name: "SwiftSourceSigLintBuildTool",
            targets: ["SwiftSourceSigLintBuildTool"]
        ),
    ],
    targets: [
        .target(name: "SwiftSourceSig"),
        .executableTarget(
            name: "SwiftSourceSigLint",
            dependencies: ["SwiftSourceSig"]
        ),
        .plugin(
            name: "SwiftSourceSigLintBuildTool",
            capability: .buildTool,
            dependencies: ["SwiftSourceSigLint"]
        ),
        .testTarget(
            name: "SwiftSourceSigTests",
            dependencies: ["SwiftSourceSig"]
        ),
    ]
)
