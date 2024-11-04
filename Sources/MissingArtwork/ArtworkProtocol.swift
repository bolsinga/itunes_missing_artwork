//
//  ArtworkProtocol.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 11/8/24.
//

import CoreGraphics
import MusicKit

// Created so Previews may use fake Artwork.
protocol ArtworkProtocol: CustomStringConvertible, Hashable, Sendable {
  var backgroundColor: CGColor? { get }
  var maximumHeight: Int { get }
}

extension Artwork: ArtworkProtocol {}
