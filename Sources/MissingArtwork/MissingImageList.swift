//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import LoadingState
import MusicKit
import SwiftUI

struct MissingImageList: View {
  let missingArtwork: MissingArtwork
  @Binding var loadingState: LoadingState<[(Artwork, LoadingState<NSImage>)]>

  @Binding var selectedArtworkImage: NSImage?

  @ViewBuilder private var artworkLoadingStatusOverlay: some View {
    if loadingState.isIdleOrLoading {
      ProgressView()
    } else if case .error(let error) = loadingState {
      Text(error.localizedDescription)
    }
  }

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack {
          ForEach(
            Binding<[(Artwork, LoadingState<NSImage>)]> {
              if let value = loadingState.value {
                return value
              }
              return []
            } set: {
              loadingState = .loaded($0)
            }, id: \.0
          ) { $artworkImage in
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
    .overlay(artworkLoadingStatusOverlay)
    .task(id: missingArtwork) {
      await loadingState.load(missingArtwork: missingArtwork)
    }
  }
}

struct MissingImageList_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: .constant(.idle),
        selectedArtworkImage: .constant(nil))

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: .constant(.loading),
        selectedArtworkImage: .constant(nil))

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: .constant(.loaded([])),
        selectedArtworkImage: .constant(nil))
    }
  }
}
