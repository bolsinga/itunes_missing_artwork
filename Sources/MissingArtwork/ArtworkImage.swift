//
//  ArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/17/22.
//

import AppKit
import MusicKit

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
}
