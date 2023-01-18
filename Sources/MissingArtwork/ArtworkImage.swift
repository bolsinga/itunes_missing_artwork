//
//  ArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/17/22.
//

import AppKit
import Foundation
import MusicKit

private enum NoImageError: Error {
  case noURL(Artwork)
}

extension NoImageError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noURL(let artwork):
      return "No Image URL Available: \(artwork.description)."
    }
  }
}

struct ArtworkImage: Equatable {
  static func == (lhs: ArtworkImage, rhs: ArtworkImage) -> Bool {
    if lhs.artwork != rhs.artwork {
      return false
    }
    switch (lhs.loadingState, rhs.loadingState) {
    case (.idle, .idle):
      return true
    case (.loading, .loading):
      return true
    case (.loaded(let lhImage), .loaded(let rhImage)):
      return lhImage == rhImage
    case (.error(_), .error(_)):
      return true
    default:
      return false
    }
  }

  let artwork: Artwork
  var loadingState: LoadingState<NSImage>

  mutating func load(artwork: Artwork) async {
    do {
      guard let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight)
      else { throw NoImageError.noURL(artwork) }

      await self.loadingState.load(url: url)
    } catch {
      self.loadingState = .error(error)
    }
  }
}
