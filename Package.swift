// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "itunes_missing_artwork",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(name: "MissingArtwork", targets: ["MissingArtwork"])
  ],
  dependencies: [
    .package(url: "https://github.com/bolsinga/LoadingState", branch: "main")
  ],
  targets: [
    .target(
      name: "MissingArtwork",
      dependencies: [
        .product(name: "LoadingState", package: "LoadingState")
      ], swiftSettings: [.unsafeFlags(["-strict-concurrency=targeted"])])
  ]
)
