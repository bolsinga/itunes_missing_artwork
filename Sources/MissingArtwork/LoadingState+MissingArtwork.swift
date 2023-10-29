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
      return String(
        localized: "iTunes Library unable to find missing artwork: \(error.localizedDescription)",
        bundle: .module,
        comment: "Error message when iTunes is unable to find missing artwork.")
    }
  }
  fileprivate var recoverySuggestion: String? {
    String(
      localized: "iTunes was unable to find any missing artwork to fix.",
      bundle: .module,
      comment: "Recovery message when iTunes is unable to find missing artwork.")
  }
}

extension LoadingState where Value == [MissingArtwork] {
  mutating func load() async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let missingArtworks = try await MissingArtwork.gatherMissingArtwork()

      self = .loaded(missingArtworks)
    } catch {
      let missingError = ITunesError.cannotFetchMissingArtwork(error)
      self = .error(missingError)
      debugPrint("Unable to fetch missing artworks: \(missingError.localizedDescription)")
    }
  }
}
