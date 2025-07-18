// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TreeSitterZortex",
    products: [
        .library(name: "TreeSitterZortex", targets: ["TreeSitterZortex"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "TreeSitterZortex",
            dependencies: [],
            path: ".",
            sources: [
                "src/parser.c",
                // NOTE: if your language has an external scanner, add it here.
            ],
            resources: [
                .copy("queries")
            ],
            publicHeadersPath: "bindings/swift",
            cSettings: [.headerSearchPath("src")]
        ),
        .testTarget(
            name: "TreeSitterZortexTests",
            dependencies: [
                "SwiftTreeSitter",
                "TreeSitterZortex",
            ],
            path: "bindings/swift/TreeSitterZortexTests"
        )
    ],
    cLanguageStandard: .c11
)
