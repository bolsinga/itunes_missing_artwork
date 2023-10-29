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
  @Binding var loadingState: LoadingState<PlatformImage>

  var body: some View {
    VStack(alignment: .center) {
      Text(
        "Partial Artwork Is Already Ready To Repair", bundle: .module,
        comment: "Text shown when a partial artwork is selected."
      ).font(.headline)
      switch loadingState {
      case .idle:
        ProgressView()
      case .loading:
        ProgressView()
      case .error(_):
        EmptyView()
      case .loaded(let platformImage):
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      }
    }
    .frame(width: width)
    .task(id: missingArtwork) {
      await loadingState.loadImage(missingArtwork: missingArtwork)
    }
  }
}
