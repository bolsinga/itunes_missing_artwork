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
  targets: [
    .target(name: "MissingArtwork", swiftSettings: [.unsafeFlags(["-strict-concurrency=targeted"])])
  ]
)
