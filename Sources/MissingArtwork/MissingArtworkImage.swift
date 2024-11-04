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
  var model: MissingArtworksModel<C>
  @State private var error: Error?

  @ViewBuilder var artworkProgress: some View {
    ZStack {
      if let backgroundColor = artwork.backgroundColor {
        Color(cgColor: backgroundColor)
          .frame(width: width, height: CGFloat(artwork.maximumHeight))
      }
      ProgressView()
    }
  }

  var body: some View {
    Group {
      if let platformImage = model.artworkImages[artwork] {
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      } else if let error {
        Text(
          "Unable to load image: \(error.localizedDescription)", bundle: .module,
          comment: "Message when an image URL cannot be loaded.")
      } else {
        artworkProgress
      }
    }
    .frame(width: width)
    .task(id: artwork) {
      do {
        try await model.load(image: artwork)
      } catch {
        self.error = error
      }
    }
  }
}

#Preview("Loading - No Background Color") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(backgroundColor: nil),
    model: MissingArtworksModel(artworkLoaderResult: .nothing)
  )
  .frame(width: 300, height: 300)
}

#Preview("Loading - Background Color") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(),
    model: MissingArtworksModel(artworkLoaderResult: .nothing)
  )
  .frame(width: 300, height: 300)
}

#Preview("Error") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(),
    model: MissingArtworksModel(artworkLoaderResult: .error(CancellationError()))
  )
  .frame(width: 300, height: 300)
}

#Preview("Image") {
  let artwork = PreviewArtwork()
  MissingArtworkImage(
    width: 300, artwork: artwork,
    model: MissingArtworksModel(artworkImages: [artwork: previewImage])
  )
  .frame(width: 300, height: 300)
}
