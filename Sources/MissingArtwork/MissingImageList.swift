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
  @Binding var artworkImages: [(Artwork, LoadingState<NSImage>)]

  @Binding var selectedArtworkImage: NSImage?

  @State private var loadingState: LoadingState<[(Artwork, LoadingState<NSImage>)]> = .idle

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
          ForEach($artworkImages, id: \.0) { $artworkImage in
            MissingArtworkImage(
              width: proxy.size.width, artwork: artworkImage.0,
              loadingState: $artworkImage.1
            )
            .onTapGesture { selectedArtworkImage = artworkImage.1.value }
            .border(
              .selection, width: selectedArtworkImage == artworkImage.1.value ? 2.0 : 0)
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
        artworkImages = artworks.map { ($0, .idle) }

        loadingState = .loaded(artworkImages)
      } catch {
        loadingState = .error(error)
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
        selectedArtworkImage: .constant(nil))
    }
  }
}
