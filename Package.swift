// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "itunes_missing_artwork",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "MissingArtwork", targets: ["MissingArtwork"]),
        .executable(name: "MissingArtworkTool", targets: ["MissingArtworkTool"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.1"),
        .package(url: "https://github.com/terwanerik/CupertinoJWT", from: "0.2.2"),
    ],
    targets: [
        .target(name: "MissingArtwork", dependencies: []),
        .executableTarget(name: "MissingArtworkTool",
            dependencies: [.target(name: "MissingArtwork"),
                           .product(name: "ArgumentParser", package: "swift-argument-parser"),
                           .product(name: "CupertinoJWT", package: "CupertinoJWT"),
            ]
        ),
    ]
)
