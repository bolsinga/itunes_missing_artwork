//
//  ArtworkLoadingImage+Load.swift
//
//
//  Created by Greg Bolsinga on 1/22/23.
//

import Foundation
import MusicKit
import os

extension Logger {
  fileprivate static let artworkLoadingImage = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "artworkLoadingImage")
}

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

extension ArtworkLoadingImage {
  private static func fetchArtworks(term: String) async throws -> [Artwork] {
    Logger.artworkLoadingImage.log("fetch: \(term, privacy: .public)")
    var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
    searchRequest.limit = 2
    let searchResponse = try await searchRequest.response()
    return searchResponse.albums.compactMap(\.artwork)
  }

  private static func search(term: String) async throws -> [ArtworkLoadingImage] {
    Logger.artworkLoadingImage.log("search: \(term, privacy: .public)")
    let artworks = try await fetchArtworks(term: term)
    if artworks.isEmpty {
      throw NoArtworkError.noneFound(term)
    }
    return artworks.map {
      ArtworkLoadingImage(artwork: $0, loadingState: PlatformImage.createArtworkModel())
    }
  }

  static func load(_ missingArtwork: MissingArtwork) async throws -> [ArtworkLoadingImage] {
    Logger.artworkLoadingImage.log("load artwork: \(missingArtwork, privacy: .public)")
    return try await search(term: missingArtwork.simpleRepresentation)
  }
}
