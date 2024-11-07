//
//  MissingArtwork+MusicKit.swift
//
//
//  Created by Greg Bolsinga on 3/19/23.
//

import Foundation
import MusicKit
import os

extension Logger {
  fileprivate static let artworkLoadingImage = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "artworkLoadingImage")
}

enum NoArtworkError: Error {
  case noneFound(String)
}

extension NoArtworkError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .noneFound(let term):
      return String(
        localized:
          "Image Search was unable to find images for \"\(term)\". Unable to repair artwork without an image.",
        bundle: .module,
        comment: "Error message when no Missing Artworks are found for search term.")
    }
  }
}

extension Song {
  func matches(_ missingArtwork: MissingArtwork) -> Bool {
    if let album = self.albums?.first {
      switch missingArtwork {
      case .ArtistAlbum(let artistName, let albumName, _):
        return self.artistName == artistName && album.title == albumName
      case .CompilationAlbum(let albumName, _):
        return (album.isCompilation != nil || album.isCompilation ?? false)
          && album.title == albumName
      }
    }
    return false
  }
}

extension MissingArtwork {
  public static func gatherMissingArtwork() async throws -> [MissingArtwork] {
    var partial = [MissingArtwork: [Int: Int]]()  // MissingItem : [discNumber: missingArtworkCount]

    let request = MusicLibrarySectionedRequest<Album, Song>()
    let response = try await request.response()
    let missingArtworkSections = response.sections.filter {
      $0.items.count { $0.artwork == nil } > 0
    }

    partial = missingArtworkSections.reduce(into: partial) { partialResult, section in
      let album = section
      section.items.forEach { song in
        let missingArtwork =
          (album.isCompilation ?? false)
          ? MissingArtwork.CompilationAlbum(album.title, .unknown)
          : MissingArtwork.ArtistAlbum(song.artistName, album.title, .unknown)

        let discNumber = song.discNumber ?? 0

        if let albumInfo = partialResult[missingArtwork] {
          // We have tracked this missingArtwork already
          if let trackCount = albumInfo[discNumber] {
            // We have tracked this missingArtwork and discNumber
            partialResult[missingArtwork]?[discNumber] = trackCount - 1
          } else {
            // We have tracked this missingArtwork but not this discNumber
            let albumTrackCount = album.trackCount
            partialResult[missingArtwork]?[discNumber] =
              albumTrackCount == 0 ? -1 : albumTrackCount - 1
          }
        } else {
          // We have not tracked this missingArtwork.
          let albumTrackCount = album.trackCount
          partialResult[missingArtwork] = [
            discNumber: albumTrackCount == 0 ? -1 : albumTrackCount - 1
          ]
        }
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

  public func matchingPartialArtworkImage() async throws -> PlatformImage {
    guard self.availability == .some else {
      fatalError(
        "Unable to get partial image for this MissingArtwork: \(String(describing: self))")
    }

    let request = MusicLibraryRequest<Song>()
    let response = try await request.response()
    let artworkSongs = response.items.filter { $0.artwork != nil }

    for artworkSong in artworkSongs {
      if let artwork = artworkSong.artwork {
        let refinedSong = try await artworkSong.with([.albums], preferredSource: .library)
        if refinedSong.matches(self) {
          return try await PlatformImage.load(artwork: artwork)
        }
      }
    }

    throw PartialArtworkImageError.noneFound
  }

  public func fetchCatalogArtworks() async throws -> [Artwork] {
    let term = self.simpleRepresentation
    Logger.artworkLoadingImage.log("search: \(term, privacy: .public)")

    var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
    searchRequest.limit = 2
    let artworks = try await searchRequest.response().albums.compactMap(\.artwork)
    if artworks.isEmpty { throw NoArtworkError.noneFound(term) }

    return artworks
  }
}
