//
//  PartialArtworkImageView.swift
//
//
//  Created by Greg Bolsinga on 3/19/23.
//

import SwiftUI

struct PartialArtworkImageView: View {
  let width: CGFloat
  let missingArtwork: MissingArtwork
  var model: ArtworksModel

  var body: some View {
    VStack(alignment: .center) {
      Text(
        "Partial Artwork Is Already Ready To Repair", bundle: .module,
        comment: "Text shown when a partial artwork is selected."
      ).font(.headline)
      if let partialLibraryImage = model.partialLibraryImages[missingArtwork] {
        switch partialLibraryImage {
        case .loading:
          ProgressView()
        case .error(_):
          EmptyView()
        case .image(let platformImage):
          platformImage.representingImage
            .resizable().aspectRatio(contentMode: .fit)
        }
      } else {
        ProgressView()
      }
    }
    .frame(width: width)
    .task(id: missingArtwork) {
      await model.load(image: missingArtwork)
    }
  }
}
