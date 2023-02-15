//
//  MissingArtwork.swift
//
//
//  Created by Greg Bolsinga on 3/28/21.
//

import Foundation
import iTunesLibrary

public enum ArtworkAvailability: Hashable, Comparable, Sendable {
  case some  // Some of the songs for the album have artwork
  case none  // None of the songs for the album have artwork
  case unknown  // Unknown if some or none of the songs for the album have artwork. Usually because the album does not have a track count.
}

public enum MissingArtwork: Hashable, Comparable, Sendable {
  case ArtistAlbum(String, String, ArtworkAvailability)
  case CompilationAlbum(String, ArtworkAvailability)
}

extension MissingArtwork: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .ArtistAlbum(artist, album, _):
      return "\(artist): \(album)"
    case let .CompilationAlbum(title, _):
      return "\(title)"
    }
  }
}

extension MissingArtwork {
  public var availability: ArtworkAvailability {
    switch self {
    case .ArtistAlbum(_, _, let availability):
      return availability
    case .CompilationAlbum(_, let availability):
      return availability
    }
  }
}

extension MissingArtwork: Identifiable {
  public var id: Self {
    self
  }
}

extension MissingArtwork {
  public var simpleRepresentation: String {
    switch self {
    case let .ArtistAlbum(artist, album, _):
      return "\(artist) \(album)"
    case let .CompilationAlbum(title, _):
      return title
    }
  }

  var fileNameRepresentation: String {
    self.simpleRepresentation.replacingOccurrences(of: " ", with: "_")
  }

  public static func gatherMissingArtwork() throws -> [MissingArtwork] {
    let itunes = try ITLibrary(apiVersion: "1.1")
    let missingItems = itunes.allMediaItems
      .filter { $0.mediaKind == .kindSong }
      .filter { !$0.hasArtworkAvailable || $0.artwork == nil }

    var partial = [MissingArtwork: [Int: Int]]()  // MissingItem : [discNumber: missingArtworkCount]

    for missingItem in missingItems {
      var discNumber = missingItem.album.discNumber
      let discCount = missingItem.album.discCount
      if discNumber == 1, discCount == 1 {
        discNumber = 0  // just use 0 for debugging ease.
      }

      let missingArtwork =
        missingItem.album.isCompilation
        ? MissingArtwork.CompilationAlbum(
          missingItem.album.title ?? "Unknown Compilation Album Title", .unknown)
        : .ArtistAlbum(
          (missingItem.artist?.name ?? missingItem.album.albumArtist) ?? "Unknown Artist Name",
          missingItem.album.title ?? missingItem.title,
          .unknown)

      if let albumInfo = partial[missingArtwork] {
        // We have tracked this missingArtwork already
        if let trackCount = albumInfo[discNumber] {
          // We have tracked this missingArtwork and discNumber
          partial[missingArtwork]?[discNumber] = trackCount - 1
        } else {
          // We have tracked this missingArtwork but not this discNumber
          let albumTrackCount = missingItem.album.trackCount
          partial[missingArtwork]?[discNumber] = albumTrackCount == 0 ? -1 : albumTrackCount - 1
        }
      } else {
        // We have not tracked this missingArtwork.
        let albumTrackCount = missingItem.album.trackCount
        partial[missingArtwork] = [discNumber: albumTrackCount == 0 ? -1 : albumTrackCount - 1]
      }
    }

    return partial.map { (key: MissingArtwork, albumInfo: [Int: Int]) in
      let value = albumInfo.values.reduce(
        0,
        { x, y in
          x + y
        })

      let availability: ArtworkAvailability = value < 0 ? .unknown : (value == 0 ? .none : .some)
      var item: MissingArtwork
      switch key {
      case .ArtistAlbum(let artist, let album, _):
        item = .ArtistAlbum(artist, album, availability)
      case .CompilationAlbum(let album, _):
        item = .CompilationAlbum(album, availability)
      }
      return item
    }
  }
}
