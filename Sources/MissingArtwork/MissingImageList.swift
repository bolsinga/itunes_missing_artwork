//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import MusicKit
import SwiftUI

struct MissingImageList: View {
  let missingArtwork: MissingArtwork
  @Binding var artworkImages: [(Artwork, LoadingState<NSImage>)]
  @Binding var loadingState: LoadingState<[Artwork]>

  @Binding var selectedArtworkImage: NSImage?

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
      await loadingState.load(missingArtwork: missingArtwork)

      if let artworks = loadingState.value {
        artworkImages = artworks.map { ($0, .idle) }
      }
    }
  }
}

struct MissingImageList_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MissingImageList(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
        artworkImages: .constant([]),
        loadingState: .constant(.idle),
        selectedArtworkImage: .constant(nil))
    }
  }
}
