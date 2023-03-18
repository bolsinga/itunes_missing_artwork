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

  var body: some View {
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

struct SingleSelectedMissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)

    SingleSelectedMissingArtworkView(
      missingArtwork: missingArtwork,
      loadingState: .constant(.idle),
      selectedArtworkImage: .constant(nil))
  }
}
