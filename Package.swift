// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "itunes_missing_artwork",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .library(name: "MissingArtwork", targets: ["MissingArtwork"]),
    .library(name: "MissingArtworkUI", targets: ["MissingArtworkUI"]),
    .executable(name: "MissingArtworkTool", targets: ["MissingArtworkTool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", "1.1.0"..."1.1.0"),
    .package(url: "https://github.com/terwanerik/CupertinoJWT", "0.2.2"..."0.2.2"),
  ],
  targets: [
    .target(name: "MissingArtwork", dependencies: []),
    .target(name: "MissingArtworkUI", dependencies: [.target(name: "MissingArtwork")]),
    .executableTarget(
      name: "MissingArtworkTool",
      dependencies: [
        .target(name: "MissingArtwork"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "CupertinoJWT", package: "CupertinoJWT"),
      ]
    ),
  ]
)
