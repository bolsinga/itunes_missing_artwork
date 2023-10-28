// swift-tools-version:5.9

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
  dependencies: [
    .package(url: "https://github.com/bolsinga/LoadingState", from: "1.0.2")
  ],
  targets: [
    .target(
      name: "MissingArtwork",
      dependencies: [
        .product(name: "LoadingState", package: "LoadingState")
      ],
      resources: [.process("Resources/Localizable.xcstrings")]
    )
  ]
)
