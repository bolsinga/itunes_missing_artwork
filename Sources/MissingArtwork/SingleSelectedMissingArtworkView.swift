//
//  SingleSelectedMissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 3/17/23.
//

import SwiftUI

struct SingleSelectedMissingArtworkView: View {
  let missingArtwork: MissingArtwork
  @Binding var loadingState: LoadingState<[ArtworkLoadingImage]>
  @Binding var selectedArtworkImage: ArtworkLoadingImage?
  @Binding var processingState: ProcessingState
  @Binding var partialImageLoadingState: MissingPlatformImageModel

  var body: some View {
    if processingState != .none {
      ProcessingStateView(missingArtwork: missingArtwork, processingState: processingState)
    } else {
      if missingArtwork.availability == .some {
        GeometryReader { proxy in
          PartialArtworkImageView(
            width: proxy.size.width,
            missingArtwork: missingArtwork, loadingState: partialImageLoadingState)
        }
      } else {
        MissingImageList(
          missingArtwork: missingArtwork,
          loadingState: $loadingState,
          selectedArtworkImage: $selectedArtworkImage
        )
      }
    }
  }
}

struct SingleSelectedMissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    let missingArtworks = [
      MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none),
      MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    ]

    SingleSelectedMissingArtworkView(
      missingArtwork: missingArtworks[0],
      loadingState: .constant(.idle),
      selectedArtworkImage: .constant(nil),
      processingState: .constant(.none),
      partialImageLoadingState: .constant(MissingArtwork.createPlatformImageModel()))

    SingleSelectedMissingArtworkView(
      missingArtwork: missingArtworks[1],
      loadingState: .constant(.idle),
      selectedArtworkImage: .constant(nil),
      processingState: .constant(.none),
      partialImageLoadingState: .constant(MissingArtwork.createPlatformImageModel()))

    SingleSelectedMissingArtworkView(
      missingArtwork: missingArtworks[1],
      loadingState: .constant(.idle),
      selectedArtworkImage: .constant(nil),
      processingState: .constant(.processing),
      partialImageLoadingState: .constant(MissingArtwork.createPlatformImageModel()))
  }
}
