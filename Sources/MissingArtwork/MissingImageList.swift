//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import MusicKit
import SwiftUI

extension Artwork: Identifiable {
  public var id: Artwork { self }
}

struct MissingImageList: View {
  let missingArtwork: MissingArtwork
  @Binding var artworkImages: [ArtworkImage]

  @Binding var selectedArtworkImage: ArtworkImage?

  @Binding var selectedArtwork: MissingArtwork?

  @State var showMissingImageListOverlayProgress: Bool = false
  @State private var missingImageListOverlayMessage: String?

  @ViewBuilder private var imageListOverlay: some View {
    if showMissingImageListOverlayProgress {
      ProgressView()
    } else if let message = missingImageListOverlayMessage {
      Text(message).textSelection(.enabled)
    }
  }

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack {
          ForEach($artworkImages, id: \.artwork) { $artworkImage in
            MissingArtworkImage(
              artwork: artworkImage.artwork, width: proxy.size.width, nsImage: $artworkImage.nsImage
            )
            .onTapGesture { selectedArtworkImage = artworkImage }
            .border(.selection, width: selectedArtworkImage == artworkImage ? 2.0 : 0)
          }
        }
      }
    }
    .overlay(imageListOverlay)
    .task {
      missingImageListOverlayMessage = nil

      showMissingImageListOverlayProgress = true
      defer {
        showMissingImageListOverlayProgress = false
      }

      do {
        artworkImages = try await fetchArtworks(
          missingArtwork: missingArtwork, term: missingArtwork.simpleRepresentation
        ).map { ArtworkImage(artwork: $0) }

        if artworkImages.isEmpty {
          missingImageListOverlayMessage = "No image for \(missingArtwork.description)"
        }
      } catch {
        if missingArtwork == selectedArtwork {
          // only show this if the error occurred with the currently selected artwork.
          missingImageListOverlayMessage =
            "Error retrieving \(missingArtwork.description). Error: \(String(describing: error.localizedDescription))"
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
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House"),
        artworkImages: .constant([]),
        selectedArtworkImage: .constant(nil),
        selectedArtwork: .constant(nil))
    }
  }
}
