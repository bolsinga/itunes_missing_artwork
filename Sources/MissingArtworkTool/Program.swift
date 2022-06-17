import ArgumentParser
import Foundation
import MissingArtwork

@main
struct Program: AsyncParsableCommand {
  @MainActor
  mutating func run() async throws {
    let model = Model()
    try await model.fetchMissingArtworks()
    let missingMediaArtworks = model.missingArtworks
    print("\(missingMediaArtworks.count) Missing Artworks")

    print("\(model.missingArtworkURLs)")
  }
}
