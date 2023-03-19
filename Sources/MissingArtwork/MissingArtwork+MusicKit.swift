//
//  MissingArtwork+MusicKit.swift
//
//
//  Created by Greg Bolsinga on 3/19/23.
//

import Foundation

#if !canImport(iTunesLibrary) && canImport(MusicKit)
  extension MissingArtwork {
    public static func gatherMissingArtwork() async throws -> [MissingArtwork] {
      // Create some fake ones for testing.
      let items: [MissingArtwork] = [
        .ArtistAlbum("The Beatles", "The White Album", .some),
        .ArtistAlbum("Wire", "Pink Flag", .none),
        .CompilationAlbum("The Lounge Ax Defense & Relocation Compact Disc", .some),
      ]
      return items
    }

    public func matchingPartialArtworkImage() async throws -> PlatformImage {
      guard self.availability == .some else {
        fatalError(
          "Unable to get partial image for this MissingArtwork: \(String(describing: self))")
      }

      throw PartialArtworkImageError.noneFound
    }
  }
#endif
