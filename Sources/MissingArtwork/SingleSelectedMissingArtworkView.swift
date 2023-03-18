//
//  SingleSelectedMissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 3/17/23.
//

import LoadingState
import SwiftUI

struct SingleSelectedMissingArtworkView: View {
  let missingArtwork: MissingArtwork
  @Binding var loadingState: LoadingState<[ArtworkLoadingImage]>
  @Binding var selectedArtworkImage: ArtworkLoadingImage?
  @Binding var processingState: ProcessingState

  var body: some View {
    if processingState != .none {
      ProcessingStateView(missingArtwork: missingArtwork, processingState: processingState)
    } else {
      if missingArtwork.availability == .some {
        Text(
          "Partial Artwork Is Already Ready To Repair", bundle: .module,
          comment: "Text shown when a partial artwork is selected."
        ).font(.headline)
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
      processingState: .constant(.none))

    SingleSelectedMissingArtworkView(
      missingArtwork: missingArtworks[1],
      loadingState: .constant(.idle),
      selectedArtworkImage: .constant(nil),
      processingState: .constant(.none))

    SingleSelectedMissingArtworkView(
      missingArtwork: missingArtworks[1],
      loadingState: .constant(.idle),
      selectedArtworkImage: .constant(nil),
      processingState: .constant(.processing))
  }
}
