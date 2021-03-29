// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "itunes_json",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.1"),
        .package(url: "https://github.com/terwanerik/CupertinoJWT", from: "0.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "itunes_json",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"),
                           .product(name: "CupertinoJWT", package: "CupertinoJWT"),
            ]
        ),
    ]
)
