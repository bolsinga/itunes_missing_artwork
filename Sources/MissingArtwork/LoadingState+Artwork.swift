//
//  LoadingState+Artwork.swift
//
//
//  Created by Greg Bolsinga on 1/22/23.
//

import Foundation
import LoadingState
import MusicKit

public enum NoArtworkError: Error {
  case noneFound(MissingArtwork)
}

extension NoArtworkError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .noneFound(let missingArtwork):
      return String(
        localized: "No image for \(missingArtwork.description)",
        bundle: .module,
        comment: "Error message when no Missing Artworks are found.")
    }
  }
}

extension LoadingState where Value == [ArtworkLoadingImage] {
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

      self = .loaded(artworks.map { ArtworkLoadingImage(artwork: $0, loadingState: .idle) })
    } catch {
      self = .error(error)
    }
  }
}
