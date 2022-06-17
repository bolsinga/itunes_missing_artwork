// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "itunes_missing_artwork",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .library(name: "MissingArtwork", targets: ["MissingArtwork"]),
    .executable(name: "MissingArtworkTool", targets: ["MissingArtworkTool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", "1.1.0"..."1.1.0")
  ],
  targets: [
    .target(name: "MissingArtwork", dependencies: [], sources: [".", "Preview Content"]),
    .executableTarget(
      name: "MissingArtworkTool",
      dependencies: [
        .target(name: "MissingArtwork"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
  ]
)
