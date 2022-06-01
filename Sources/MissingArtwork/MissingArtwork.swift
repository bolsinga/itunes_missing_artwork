//
//  MissingArtwork.swift
//
//
//  Created by Greg Bolsinga on 3/28/21.
//

import Foundation
import iTunesLibrary

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
  var simpleRepresentation: String {
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

  public static func gatherMissingArtwork() throws -> [MissingArtwork] {
    let itunes = try ITLibrary(apiVersion: "1.1")

    return itunes.allMediaItems
      .filter { $0.mediaKind == .kindSong }
      .filter { !$0.hasArtworkAvailable || $0.artwork == nil }
      .compactMap {
        $0.album.isCompilation
          ? .CompilationAlbum($0.album.title!)
          : .ArtistAlbum($0.artist?.name ?? $0.album.albumArtist!, $0.album.title ?? $0.title)
      }
  }
}
