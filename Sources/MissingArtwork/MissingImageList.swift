//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import MusicKit
import SwiftUI

struct MissingImageList<C: MissingArtworkProtocol>: View {
  let missingArtwork: MissingArtwork
  var loadingState: LoadingModel<[LoadingImage<C>], MissingArtwork>

  @Binding var selectedArtworkImage: LoadingImage<C>?

  var body: some View {
    VStack {
      if loadingState.isIdleOrLoading {
        ProgressView()
      } else if let error = loadingState.error {
        VStack(alignment: .center) {
          Text(error.localizedDescription)
          if error as? NoArtworkError == nil {
            Button {
              Task { await loadingState.reload(missingArtwork) }
            } label: {
              Text(
                "Retry Loading Image", bundle: .module,
                comment: "Button title to retry loading an image.")
            }
          }
        }
      } else if let values = loadingState.value {
        if values.isEmpty {
          Text(
            "No Images Available", bundle: .module,
            comment: "Shown when no images are loaded for repair.")
        } else {
          if missingArtwork.availability == .none {
            Text(
              "Select an Image to Use for Repair", bundle: .module,
              comment:
                "Shown when Missing Image List has images for a missing artwork with no artwork."
            )
            .font(.headline)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
          }
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
    }
    .task(id: missingArtwork) { await loadingState.load(missingArtwork) }
  }
}

#Preview("Loading") {
  MissingImageList<Artwork>(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
    loadingState: LoadingModel(),
    selectedArtworkImage: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Loaded Empty") {
  MissingImageList<Artwork>(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
    loadingState: LoadingModel(item: []),
    selectedArtworkImage: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Loaded Values - Availability None") {
  MissingImageList(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
    loadingState: LoadingModel(item: [
      LoadingImage(
        artwork: PreviewArtwork(), loadingState: LoadingModel(item: previewImage))
    ]),
    selectedArtworkImage: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Loaded Values - Availability Some") {
  MissingImageList(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    loadingState: LoadingModel(item: [
      LoadingImage(
        artwork: PreviewArtwork(), loadingState: LoadingModel(item: previewImage))
    ]),
    selectedArtworkImage: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Error - NoArtworkError") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  MissingImageList<Artwork>(
    missingArtwork: missingArtwork,
    loadingState: LoadingModel(
      error: NoArtworkError.noneFound(missingArtwork.simpleRepresentation)),
    selectedArtworkImage: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Error") {
  MissingImageList<Artwork>(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
    loadingState: LoadingModel(error: CancellationError()),
    selectedArtworkImage: .constant(nil)
  )
  .frame(width: 300, height: 300)
}
