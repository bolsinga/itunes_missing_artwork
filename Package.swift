// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "itunes_missing_artwork",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  products: [
    .library(name: "MissingArtwork", targets: ["MissingArtwork"])
  ],
  targets: [
    .target(
      name: "MissingArtwork",
      resources: [.process("Resources/Localizable.xcstrings")]
    )
  ]
)
