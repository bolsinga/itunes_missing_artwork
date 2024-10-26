//
//  LoadingState+PlatformImage+Artwork.swift
//
//
//  Created by Greg Bolsinga on 1/21/23.
//

import Foundation
import MusicKit

enum ArtworkImageError: Error {
  case noURL(Artwork)
}

extension ArtworkImageError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .noURL(let artwork):
      return String(
        localized: "No Image URL Available: \(artwork.description).",
        bundle: .module,
        comment: "Error message when MusicKit Artwork does not have an URL.")
    }
  }
}

extension LoadingState where Value == PlatformImage {
  mutating func load(artwork: Artwork) async {
    do {
      self = .loaded(try await PlatformImage.load(artwork: artwork))
    } catch {
      self = .error(error)
    }
  }
}
