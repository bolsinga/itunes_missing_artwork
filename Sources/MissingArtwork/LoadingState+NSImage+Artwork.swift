//
//  LoadingState+NSImage+Artwork.swift
//
//
//  Created by Greg Bolsinga on 1/21/23.
//

import AppKit
import Foundation
import MusicKit

private enum ArtworkImageError: Error {
  case noURL(Artwork)
}

extension ArtworkImageError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noURL(let artwork):
      return String(
        localized: "No Image URL Available: \(artwork.description).",
        bundle: .module,
        comment: "Error message when MusicKit Artwork does not have an URL.")
    }
  }
}

extension LoadingState where Value == NSImage {
  mutating func load(artwork: Artwork) async {
    do {
      guard let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight)
      else { throw ArtworkImageError.noURL(artwork) }

      await self.load(url: url)
    } catch {
      self = .error(error)
    }
  }
}
