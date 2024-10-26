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
  var loadingState: MissingPlatformImageModel

  var body: some View {
    VStack(alignment: .center) {
      Text(
        "Partial Artwork Is Already Ready To Repair", bundle: .module,
        comment: "Text shown when a partial artwork is selected."
      ).font(.headline)
      if loadingState.isIdleOrLoading {
        ProgressView()
      } else if loadingState.isError {
        EmptyView()
      } else if let platformImage = loadingState.value {
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      }
    }
    .frame(width: width)
    .task(id: missingArtwork) {
      await loadingState.load(missingArtwork)
    }
  }
}
