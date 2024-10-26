//
//  LoadingState+Artwork.swift
//
//
//  Created by Greg Bolsinga on 1/22/23.
//

import Foundation
import MusicKit

public enum NoArtworkError: Error {
  case noneFound(String)
}

extension NoArtworkError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .noneFound(let term):
      return String(
        localized:
          "Image Search was unable to find images for \"\(term)\". Unable to repair artwork without an image.",
        bundle: .module,
        comment: "Error message when no Missing Artworks are found for search term.")
    }
  }
}

extension LoadingState where Value == [ArtworkLoadingImage] {
  private func fetchArtworks(term: String) async throws -> [Artwork] {
    var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
    searchRequest.limit = 2
    let searchResponse = try await searchRequest.response()
    return searchResponse.albums.compactMap(\.artwork)
  }

  mutating func search(term: String) async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let artworks = try await fetchArtworks(term: term)
      if artworks.isEmpty {
        throw NoArtworkError.noneFound(term)
      }

      self = .loaded(
        artworks.map {
          ArtworkLoadingImage(artwork: $0, loadingState: PlatformImage.createArtworkModel())
        }
      )
    } catch {
      self = .error(error)
    }
  }

  mutating func load(missingArtwork: MissingArtwork) async {
    await search(term: missingArtwork.simpleRepresentation)
  }
}
