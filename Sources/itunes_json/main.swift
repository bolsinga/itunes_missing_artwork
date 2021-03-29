import Foundation

do {
    let missingMediaArtworks = try MissingArtwork.gatherMissingArtwork()
    print("\(missingMediaArtworks.count) Missing Artworks:")
    missingMediaArtworks.sorted().forEach { print("\($0.searchQueryRepresentation)") }
} catch {
    print("unable to get missing art")
    exit(1)
}
