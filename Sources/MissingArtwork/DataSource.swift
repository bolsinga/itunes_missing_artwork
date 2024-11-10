//
//  DataSource.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 11/10/24.
//

enum DataSource: String, CaseIterable, Identifiable {
  case musicKit = "Music"
  #if canImport(iTunesLibrary)
    case itunes = "Classic"
  #endif

  #if canImport(iTunesLibrary)
    var toggle: Bool {
      get {
        switch self {
        case .itunes:
          return false
        case .musicKit:
          return true
        }
      }
      set {
        self = newValue ? .musicKit : .itunes
      }
    }
  #endif

  var id: DataSource { self }
}

extension DataSource {
  func gatherMissingArtwork() async throws -> [MissingArtwork] {
    switch self {
    #if canImport(iTunesLibrary)
      case .itunes:
        return try await MissingArtwork.itunes_gatherMissingArtwork()
    #endif
    case .musicKit:
      return try await MissingArtwork.gatherMissingArtwork()
    }
  }
}

extension DataSource {
  @MainActor
  func matchingPartialArtworkImage(_ missingArtwork: MissingArtwork) async throws -> PlatformImage {
    switch self {
    #if canImport(iTunesLibrary)
      case .itunes:
        return try await missingArtwork.itunes_matchingPartialArtworkImage()
    #endif
    case .musicKit:
      return try await missingArtwork.matchingPartialArtworkImage()
    }
  }

}
