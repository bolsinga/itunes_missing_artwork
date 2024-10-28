//
//  SingleSelectedMissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 3/17/23.
//

import SwiftUI

struct SingleSelectedMissingArtworkView: View {
  let missingArtwork: MissingArtwork
  @Binding var loadingState: MissingArtworkLoadingImageModel
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
          loadingState: loadingState,
          selectedArtworkImage: $selectedArtworkImage
        )
      }
    }
  }
}

#Preview {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none),
    loadingState: .constant(MissingArtwork.createArtworkLoadingImageModel()),
    selectedArtworkImage: .constant(nil),
    processingState: .constant(.none),
    partialImageLoadingState: .constant(MissingArtwork.createPlatformImageModel()))
}
#Preview {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    loadingState: .constant(MissingArtwork.createArtworkLoadingImageModel()),
    selectedArtworkImage: .constant(nil),
    processingState: .constant(.none),
    partialImageLoadingState: .constant(MissingArtwork.createPlatformImageModel()))
}
#Preview {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    loadingState: .constant(MissingArtwork.createArtworkLoadingImageModel()),
    selectedArtworkImage: .constant(nil),
    processingState: .constant(.processing),
    partialImageLoadingState: .constant(MissingArtwork.createPlatformImageModel()))
}
