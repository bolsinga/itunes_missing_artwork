//
//  LoadingModel+MissingArtwork.swift
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

extension MissingArtwork {
  static func createModel() -> LoadingModel<[MissingArtwork], Void> {
    LoadingModel<[MissingArtwork], Void> { _ in
      do {
        return (try await MissingArtwork.gatherMissingArtwork(), nil)
      } catch {
        let missingError = ITunesError.cannotFetchMissingArtwork(error)
        debugPrint("Unable to fetch missing artworks: \(missingError.localizedDescription)")
        return (nil, missingError)
      }
    }
  }
}
