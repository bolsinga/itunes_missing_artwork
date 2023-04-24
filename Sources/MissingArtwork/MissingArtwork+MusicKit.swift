//
//  MissingArtwork+MusicKit.swift
//
//
//  Created by Greg Bolsinga on 3/19/23.
//

#if !canImport(iTunesLibrary) && canImport(MusicKit)
  import MusicKit
  import LoadingState

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

      let request = MusicLibraryRequest<Song>()
      let response = try await request.response()
      let missingArtworkSongs = response.items.filter { $0.artwork == nil }

      for song in missingArtworkSongs {
        let refinedSong = try await song.with([.albums], preferredSource: .library)
        if let album = refinedSong.albums?.first {
          let missingArtwork =
            (album.isCompilation ?? false)
            ? MissingArtwork.CompilationAlbum(album.title, .unknown)
            : MissingArtwork.ArtistAlbum(refinedSong.artistName, album.title, .unknown)

          let discNumber = refinedSong.discNumber ?? 0

          if let albumInfo = partial[missingArtwork] {
            // We have tracked this missingArtwork already
            if let trackCount = albumInfo[discNumber] {
              // We have tracked this missingArtwork and discNumber
              partial[missingArtwork]?[discNumber] = trackCount - 1
            } else {
              // We have tracked this missingArtwork but not this discNumber
              let albumTrackCount = album.trackCount
              partial[missingArtwork]?[discNumber] =
                albumTrackCount == 0 ? -1 : albumTrackCount - 1
            }
          } else {
            // We have not tracked this missingArtwork.
            let albumTrackCount = album.trackCount
            partial[missingArtwork] = [
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
            var loadingState: LoadingState<PlatformImage> = .idle
            await loadingState.load(artwork: artwork)
            if let platformImage = loadingState.value {
              return platformImage
            }
          }
        }
      }

      throw PartialArtworkImageError.noneFound
    }
  }
#endif
