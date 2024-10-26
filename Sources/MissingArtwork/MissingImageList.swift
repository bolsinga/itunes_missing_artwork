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
  var loadingState: MissingArtworkLoadingImageModel

  @Binding var selectedArtworkImage: ArtworkLoadingImage?

  @ViewBuilder private var artworkLoadingStatusOverlay: some View {
    if loadingState.isIdleOrLoading {
      ProgressView()
    } else if let error = loadingState.error {
      VStack(alignment: .center) {
        Text(error.localizedDescription)
        if error as? NoArtworkError == nil {
          Button {
            Task {
              await loadingState.load(missingArtwork)
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

  var body: some View {
    VStack {
      if missingArtwork.availability == .none, loadingState.value != nil {
        Text(
          "Select an Image to Use for Repair", bundle: .module,
          comment: "Shown when Missing Image List has images for a missing artwork with no artwork."
        )
        .font(.headline)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
      }
      if let values = loadingState.value {
        GeometryReader { proxy in
          List(values, id: \.artwork, selection: $selectedArtworkImage) {
            artworkImage in
            MissingArtworkImage(
              width: proxy.size.width, artwork: artworkImage.artwork,
              loadingState: artworkImage.loadingState
            )
            .tag(artworkImage)
          }
        }
      }
    }
    .overlay(artworkLoadingStatusOverlay)
    .task(id: missingArtwork) {
      await loadingState.load(missingArtwork)
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
        loadingState: MissingArtworkLoadingImageModel(),
        selectedArtworkImage: .constant(nil))

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: MissingArtworkLoadingImageModel(),
        selectedArtworkImage: .constant(nil))

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: MissingArtworkLoadingImageModel(item: []),
        selectedArtworkImage: .constant(nil))

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: MissingArtworkLoadingImageModel(
          error: NoArtworkError.noneFound(missingArtwork.simpleRepresentation)),
        selectedArtworkImage: .constant(nil))

      MissingImageList(
        missingArtwork: missingArtwork,
        loadingState: MissingArtworkLoadingImageModel(error: MyError.retriableError),
        selectedArtworkImage: .constant(nil))
    }
  }
}
