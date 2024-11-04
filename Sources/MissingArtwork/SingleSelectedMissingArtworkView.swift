//
//  SingleSelectedMissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 3/17/23.
//

import SwiftUI

struct SingleSelectedMissingArtworkView: View {
  let missingArtwork: MissingArtwork
  var model: ArtworksModel
  @Binding var loadingState: MissingArtworkLoadingImageModel
  @Binding var selectedArtworkImage: ArtworkLoadingImage?
  @Binding var processingState: ProcessingState

  var body: some View {
    if processingState != .none {
      ProcessingStateView(missingArtwork: missingArtwork, processingState: processingState)
    } else {
      if missingArtwork.availability == .some {
        GeometryReader { proxy in
          PartialArtworkImageView(
            width: proxy.size.width, missingArtwork: missingArtwork, model: model)
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
    model: ArtworksModel(),
    loadingState: .constant(LoadingModel()),
    selectedArtworkImage: .constant(nil),
    processingState: .constant(.none))
}
#Preview {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    model: ArtworksModel(),
    loadingState: .constant(LoadingModel()),
    selectedArtworkImage: .constant(nil),
    processingState: .constant(.none))
}
#Preview {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    model: ArtworksModel(),
    loadingState: .constant(LoadingModel()),
    selectedArtworkImage: .constant(nil),
    processingState: .constant(.processing))
}
