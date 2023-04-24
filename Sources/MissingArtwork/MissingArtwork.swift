//
//  MissingArtwork.swift
//
//
//  Created by Greg Bolsinga on 3/28/21.
//

import Foundation

enum PartialArtworkImageError: Error {
  case noneFound
}

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
}
