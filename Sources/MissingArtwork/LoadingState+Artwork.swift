//
//  LoadingState+Artwork.swift
//
//
//  Created by Greg Bolsinga on 1/22/23.
//

import AppKit
import Foundation
import MusicKit

private enum NoArtworkError: Error {
  case noneFound(MissingArtwork)
}

extension NoArtworkError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noneFound(let missingArtwork):
      return String(
        localized: "No image for \(missingArtwork.description)",
        comment: "Error message when no Missing Artworks are found.")
    }
  }
}

extension LoadingState where Value == [(Artwork, LoadingState<NSImage>)] {
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

      self = .loaded(artworks.map { ($0, .idle) })
    } catch {
      self = .error(error)
    }
  }
}
