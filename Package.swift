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
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.15.0"),
    ],
    targets: [
        .target(
            name: "SwiftSourceSig",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
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
