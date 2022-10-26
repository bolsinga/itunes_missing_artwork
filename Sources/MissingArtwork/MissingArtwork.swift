//
//  MissingArtwork.swift
//
//
//  Created by Greg Bolsinga on 3/28/21.
//

import Foundation
import iTunesLibrary

public enum ArtworkAvailability {
  case some  // Some of the songs for the album have artwork
  case none  // None of the songs for the album have artwork
}

public enum MissingArtwork: Hashable, Comparable {
  case ArtistAlbum(String, String)
  case CompilationAlbum(String)
}

extension MissingArtwork: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .ArtistAlbum(artist, album):
      return "\(artist): \(album)"
    case let .CompilationAlbum(title):
      return "\(title)"
    }
  }
}

extension MissingArtwork: Identifiable {
  public var id: String {
    self.simpleRepresentation
  }
}

extension MissingArtwork {
  public var simpleRepresentation: String {
    switch self {
    case let .ArtistAlbum(artist, album):
      return "\(artist) \(album)"
    case let .CompilationAlbum(title):
      return title
    }
  }

  var fileNameRepresentation: String {
    self.simpleRepresentation.replacingOccurrences(of: " ", with: "_")
  }

  public static func gatherMissingArtwork() throws -> [(MissingArtwork, ArtworkAvailability)] {
    let itunes = try ITLibrary(apiVersion: "1.1")
    let missingItems = itunes.allMediaItems
      .filter { $0.mediaKind == .kindSong }
      .filter { !$0.hasArtworkAvailable || $0.artwork == nil }

    var partial = [MissingArtwork: Int]()  // MissingItem to missingArtworkCount

    for missingItem in missingItems {
      let missingArtwork =
        missingItem.album.isCompilation
        ? MissingArtwork.CompilationAlbum(missingItem.album.title!)
        : .ArtistAlbum(
          missingItem.artist?.name ?? missingItem.album.albumArtist!,
          missingItem.album.title ?? missingItem.title)

      if let trackCount = partial[missingArtwork] {
        partial[missingArtwork] = trackCount - 1
      } else {
        partial[missingArtwork] = missingItem.album.trackCount - 1
      }
    }

    return partial.map { (key: MissingArtwork, value: Int) in
      (key, value != 0 ? .some : .none)
    }
  }
}
