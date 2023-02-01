//
//  LoadingState+MissingArtwork.swift
//
//
//  Created by Greg Bolsinga on 1/20/23.
//

import Foundation

private enum ITunesError: Error {
  case cannotFetchMissingArtwork(Error)
}

extension ITunesError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .cannotFetchMissingArtwork(let error):
      return "iTunes Library unable to find missing artwork: \(error.localizedDescription)"
    }
  }
  fileprivate var recoverySuggestion: String? {
    "iTunes was unable to find any missing artwork to fix."
  }
}

extension LoadingState where Value == [MissingArtwork] {
  private func fetchMissingArtworks() async throws -> [MissingArtwork] {
    async let missingArtworks = try MissingArtwork.gatherMissingArtwork()
    return try await missingArtworks
  }

  mutating func load() async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let missingArtworks = try await fetchMissingArtworks()

      self = .loaded(missingArtworks)
    } catch {
      let missingError = ITunesError.cannotFetchMissingArtwork(error)
      self = .error(missingError)
      debugPrint("Unable to fetch missing artworks: \(missingError.localizedDescription)")
    }
  }
}
