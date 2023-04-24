//
//  ProcessingStateView.swift
//
//
//  Created by Greg Bolsinga on 3/18/23.
//

import SwiftUI

struct ProcessingStateView: View {
  let missingArtwork: MissingArtwork
  let processingState: ProcessingState

  private var processedStateDescription: String {
    switch processingState {
    case .none:
      return String(
        localized: "\(String(describing: missingArtwork)) has not been repaired yet.",
        bundle: .module,
        comment: "string describing when a missing artwork has not yet been repaired.")
    case .processing:
      return String(
        localized: "\(String(describing: missingArtwork)) is being repaired.",
        bundle: .module,
        comment: "string describing when a missing artwork is being repaired.")
    case .success:
      return String(
        localized: "\(String(describing: missingArtwork)) has sucessfully been repaired.",
        bundle: .module,
        comment: "string describing when a missing artwork has already been successfully repaired.")
    case .failure:
      return String(
        localized: "\(String(describing: missingArtwork)) has failed to be repaired.",
        bundle: .module,
        comment: "string describing when a missing artwork has failed to be repaired.")
    }
  }

  var body: some View {
    HStack {
      Text(processedStateDescription)
      processingState.representingView
    }
  }
}

struct ProcessingStateView_Previews: PreviewProvider {
  static var previews: some View {
    let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some)

    ProcessingStateView(missingArtwork: missingArtwork, processingState: .none)

    ProcessingStateView(missingArtwork: missingArtwork, processingState: .processing)

    ProcessingStateView(missingArtwork: missingArtwork, processingState: .failure)

    ProcessingStateView(missingArtwork: missingArtwork, processingState: .success)
  }
}
