// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "itunes_missing_artwork",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .library(name: "MissingArtwork", targets: ["MissingArtwork"])
  ],
  targets: [
    .target(name: "MissingArtwork")
  ]
)
