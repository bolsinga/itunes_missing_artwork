//
//  SingleSelectedMissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 3/17/23.
//

import SwiftUI

struct SingleSelectedMissingArtworkView<C: ArtworkProtocol>: View {
  let missingArtwork: MissingArtwork
  var model: MissingArtworksModel<C>
  @Binding var selectedArtwork: C?
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
          missingArtwork: missingArtwork, model: model, selectedArtwork: $selectedArtwork)
      }
    }
  }
}

#Preview("No Artwork - Loading - Not Processed") {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none),
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtwork: .constant(nil),
    processingState: .constant(.none)
  )
  .frame(width: 300, height: 300)
}

#Preview("Some Artwork - Loading - Not Processed") {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtwork: .constant(nil),
    processingState: .constant(.none)
  )
  .frame(width: 300, height: 300)
}

#Preview("Some Artwork - Loading - Processing") {
  SingleSelectedMissingArtworkView(
    missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtwork: .constant(nil),
    processingState: .constant(.processing)
  )
  .frame(width: 300, height: 300)
}
