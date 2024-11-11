//
//  MissingArtwork+iTunesLibrary.swift
//
//
//  Created by Greg Bolsinga on 3/19/23.
//

#if canImport(iTunesLibrary)
  @preconcurrency import iTunesLibrary

  extension ITLibMediaItem {
    func matches(_ missingArtwork: MissingArtwork) -> Bool {
      switch missingArtwork {
      case .ArtistAlbum(let artist, let album, _):
        return !self.album.isCompilation
          && (artist == self.artist?.name || artist == self.album.albumArtist)
          && (album == self.album.title || album == self.title)
      case .CompilationAlbum(let album, _):
        return self.album.isCompilation && self.album.title == album
      }
    }
  }

  extension MissingArtwork {
    public static func itunes_gatherMissingArtwork() async throws -> [MissingArtwork] {
      let itunes = try ITLibrary(apiVersion: "1.1")
      async let missingItems = itunes.allMediaItems
        .filter { $0.mediaKind == .kindSong }
        .filter { !$0.hasArtworkAvailable || $0.artwork == nil }

      var partial = [MissingArtwork: [Int: Int]]()  // MissingItem : [discNumber: missingArtworkCount]

      for missingItem in await missingItems {
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

    @MainActor
    public func itunes_matchingPartialArtworkImage() async throws -> PlatformImage {
      guard self.availability == .some else {
        fatalError(
          "Unable to get partial image for this MissingArtwork: \(String(describing: self))")
      }

      let itunes = try ITLibrary(apiVersion: "1.1")
      async let artworkItems = itunes.allMediaItems
        .filter { $0.mediaKind == .kindSong }
        .filter { $0.hasArtworkAvailable }
        .filter { $0.artwork != nil }
        .filter { $0.artwork?.image != nil }

      for artworkItem in await artworkItems {
        if artworkItem.matches(self), let nsImage = artworkItem.artwork?.image {
          return PlatformImage(image: nsImage)
        }
      }
      throw PartialArtworkImageError.noneFound
    }
  }
#endif
