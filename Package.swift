// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftLexer",
    products: [
        .library(
            name: "SwiftLexer",
            targets: ["SwiftLexer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/yassram/SwiLex.git", .upToNextMinor(from: "1.1.0")),
    ],
    targets: [
        .target(
            name: "SwiftLexer",
            dependencies: [
                "SwiLex"
            ]),
        .testTarget(
            name: "SwiftLexerTests",
            dependencies: ["SwiftLexer"]),
    ]
)
