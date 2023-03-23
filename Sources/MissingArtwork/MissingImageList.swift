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
  @Binding var loadingState: LoadingState<[ArtworkLoadingImage]>

  @Binding var selectedArtworkImage: ArtworkLoadingImage?

  @ViewBuilder private var artworkLoadingStatusOverlay: some View {
    if loadingState.isIdleOrLoading {
      ProgressView()
    } else if case .error(let error) = loadingState {
      VStack(alignment: .center) {
        Text(error.localizedDescription)
        if error as? NoArtworkError == nil {
          Button {
            Task {
              loadingState = .idle
              await loadingState.load(missingArtwork: missingArtwork)
            }
          } label: {
            Text(
              "Retry Loading Image", bundle: .module,
              comment: "Button title to retry loading an image.")
          }
        }
      }
    }
  }

  private var missingArtworkImages: Binding<[ArtworkLoadingImage]> {
    Binding<[ArtworkLoadingImage]> {
      if let value = loadingState.value {
        return value
      }
      return []
    } set: {
      loadingState = .loaded($0)
    }
  }

  var body: some View {
    VStack {
      if missingArtwork.availability == .none, !missingArtworkImages.isEmpty {
        Text(
          "Select an Image to Use for Repair", bundle: .module,
          comment: "Shown when Missing Image List has images for a missing artwork with no artwork."
        )
        .font(.headline)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
      }
      GeometryReader { proxy in
        List(missingArtworkImages, id: \.artwork, selection: $selectedArtworkImage) {
          $artworkImage in
          MissingArtworkImage(
            width: proxy.size.width, artwork: artworkImage.artwork,
            loadingState: $artworkImage.loadingState
          )
          .tag(artworkImage)
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
  enum MyError: Error {
    case retriableError
  }

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

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: .constant(
          .error(NoArtworkError.noneFound(missingArtwork.simpleRepresentation))),
        selectedArtworkImage: .constant(nil))

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: .constant(.error(MyError.retriableError)),
        selectedArtworkImage: .constant(nil))
    }
  }
}
