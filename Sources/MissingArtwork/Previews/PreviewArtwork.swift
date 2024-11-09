//
//  PreviewArtwork.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 11/8/24.
//

import CoreGraphics

struct PreviewArtwork: ArtworkProtocol {
  var backgroundColor: CGColor?
  var maximumHeight: Int { 300 }

  internal init(backgroundColor: CGColor? = CGColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)) {
    self.backgroundColor = backgroundColor
  }
}
