//
//  PartialArtworkImageView.swift
//
//
//  Created by Greg Bolsinga on 3/19/23.
//

import SwiftUI

struct PartialArtworkImageView<C: ArtworkProtocol>: View {
  let width: CGFloat
  let missingArtwork: MissingArtwork
  var model: MissingArtworksModel<C>
  @State private var error: Error?

  var body: some View {
    VStack(alignment: .center) {
      Text(
        "Partial Artwork Is Already Ready To Repair", bundle: .module,
        comment: "Text shown when a partial artwork is selected."
      ).font(.headline)
      if let platformImage = model.partialLibraryImages[missingArtwork] {
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      } else if let error {
        Text(
          "Error loading partial artwork Image: \(error.localizedDescription)", bundle: .module,
          comment: "Message shown when an error occurs loading a partial artwork image.")
      } else {
        ProgressView()
      }
    }
    .frame(width: width)
    .task(id: missingArtwork) {
      do {
        try await model.load(image: missingArtwork)
      } catch {
        self.error = error
      }
    }
  }
}
