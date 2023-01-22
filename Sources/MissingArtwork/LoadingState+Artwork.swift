//
//  LoadingState+Artwork.swift
//
//
//  Created by Greg Bolsinga on 1/22/23.
//

import Foundation
import MusicKit

private enum NoArtworkError: Error {
  case noneFound(MissingArtwork)
}

extension NoArtworkError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noneFound(let missingArtwork):
      return "No image for \(missingArtwork.description)"
    }
  }
}

extension LoadingState where Value == [Artwork] {
  private func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws -> [Artwork]
  {
    var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
    searchRequest.limit = 2
    let searchResponse = try await searchRequest.response()
    return searchResponse.albums.compactMap(\.artwork)
  }

  mutating func load(missingArtwork: MissingArtwork) async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let artworks = try await fetchArtworks(
        missingArtwork: missingArtwork, term: missingArtwork.simpleRepresentation)
      if artworks.isEmpty {
        throw NoArtworkError.noneFound(missingArtwork)
      }

      self = .loaded(artworks)
    } catch {
      self = .error(error)
    }
  }
}
