//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import MusicKit
import SwiftUI

private enum NoArtworkError: Error {
  case noneFound(MissingArtwork)
  case error(Error, MissingArtwork)
}

extension NoArtworkError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noneFound(let missingArtwork):
      return "No image for \(missingArtwork.description)"
    case .error(let error, let missingArtwork):
      return "Error retrieving \(missingArtwork.description). Error: \(error.localizedDescription)"
    }
  }
}

struct MissingImageList: View {
  let missingArtwork: MissingArtwork
  @Binding var artworkImages: [ArtworkImage]

  @Binding var selectedArtworkImage: ArtworkImage?

  @Binding var selectedArtwork: MissingArtwork?

  @State private var loadingState: LoadingState<[ArtworkImage]> = .idle

  @ViewBuilder private var imageListOverlay: some View {
    if loadingState.isIdleOrLoading {
      ProgressView()
    } else if case .error(let error) = loadingState {
      Text("\(error.localizedDescription)")
    }
  }

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack {
          ForEach($artworkImages, id: \.artwork) { $artworkImage in
            MissingArtworkImage(
              width: proxy.size.width, artwork: artworkImage.artwork,
              loadingState: $artworkImage.loadingState
            )
            .onTapGesture { selectedArtworkImage = artworkImage }
            .border(.selection, width: selectedArtworkImage == artworkImage ? 2.0 : 0)
          }
        }
      }
    }
    .overlay(imageListOverlay)
    .task {
      guard artworkImages.isEmpty else {
        loadingState = .loaded(artworkImages)
        return
      }

      loadingState = .loading

      do {
        let artworks = try await fetchArtworks(
          missingArtwork: missingArtwork, term: missingArtwork.simpleRepresentation)
        if artworks.isEmpty {
          throw NoArtworkError.noneFound(missingArtwork)
        }
        artworkImages = artworks.map { ArtworkImage(artwork: $0, loadingState: .idle) }

        loadingState = .loaded(artworkImages)
      } catch {
        if missingArtwork == selectedArtwork {
          // only show this if the error occurred with the currently selected artwork.
          loadingState = .error(error)
        }
      }
    }
  }

  private func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws -> [Artwork]
  {
    var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
    searchRequest.limit = 2
    let searchResponse = try await searchRequest.response()
    return searchResponse.albums.compactMap(\.artwork)
  }
}

struct MissingImageList_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MissingImageList(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
        artworkImages: .constant([]),
        selectedArtworkImage: .constant(nil),
        selectedArtwork: .constant(nil))
    }
  }
}
