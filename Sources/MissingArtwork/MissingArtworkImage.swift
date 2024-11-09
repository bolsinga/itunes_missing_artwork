//
//  MissingArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/8/22.
//

import SwiftUI

struct MissingArtworkImage<C: ArtworkProtocol>: View {
  let width: CGFloat

  let artwork: C
  var loadingState: LoadingModel<PlatformImage, C>

  var body: some View {
    Group {
      if loadingState.isIdleOrLoading {
        ZStack {
          if let backgroundColor = artwork.backgroundColor {
            Color(cgColor: backgroundColor)
              .frame(width: width, height: CGFloat(artwork.maximumHeight))
          }
          ProgressView()
        }
      } else if let error = loadingState.error {
        Text(
          "Unable to load image: \(error.localizedDescription)", bundle: .module,
          comment: "Message when an image URL cannot be loaded.")
      } else if let platformImage = loadingState.value {
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      }
    }
    .frame(width: width)
    .task { await loadingState.load(artwork) }
  }
}

#Preview("Loading - No Background Color") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(backgroundColor: nil), loadingState: LoadingModel()
  )
  .frame(width: 300, height: 300)
}

#Preview("Loading - Background Color") {
  MissingArtworkImage(width: 300, artwork: PreviewArtwork(), loadingState: LoadingModel())
    .frame(width: 300, height: 300)
}

#Preview("Error") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(), loadingState: LoadingModel(error: CancellationError())
  )
  .frame(width: 300, height: 300)
}

#Preview("Image") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(),
    loadingState: LoadingModel(item: previewImage)
  )
  .frame(width: 300, height: 300)
}
