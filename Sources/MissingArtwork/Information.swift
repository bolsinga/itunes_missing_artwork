//
//  Information.swift
//
//
//  Created by Greg Bolsinga on 2/6/23.
//

import SwiftUI

enum ImageRepair {
  case ready  // image is ready for repair
  case notSelected  // no image is selected for repair
  case notAvailable  // no image is available to select to repair
}

struct Information: View {
  let missingArtwork: MissingArtwork
  let imageRepair: ImageRepair
  let processingState: ProcessingState

  @ViewBuilder private var nameView: some View {
    switch missingArtwork {
    case .ArtistAlbum(let artist, let album, _):
      VStack(alignment: .leading) {
        Text(album)
          .font(.headline)
        Text(artist)
          .font(.caption)

      }
    case .CompilationAlbum(let album, _):
      HStack {
        Text(album)
          .font(.headline)
      }
    }
  }

  @ViewBuilder private var imageRepairView: some View {
    switch imageRepair {
    case .ready:
      Text(
        "Image Ready", bundle: .module,
        comment: "Help string shown when image is ready for fixing.")
    case .notSelected:
      Text(
        "No Image Selected", bundle: .module,
        comment: "Help string shown when no image has been selected for fixing.")
    case .notAvailable:
      Text(
        "No Image Available", bundle: .module,
        comment: "Help string shown when no image is available for fixing.")
    }
  }

  var body: some View {
    HStack {
      nameView
      Spacer()
      imageRepairView
      processingState.representingView
    }
    .padding(.all)
  }
}

struct Information_Previews: PreviewProvider {
  static var previews: some View {
    let album = MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none)
    let compilation = MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .some)

    Information(missingArtwork: album, imageRepair: .notAvailable, processingState: .none)
    Information(
      missingArtwork: compilation, imageRepair: .notSelected, processingState: .processing)
    Information(missingArtwork: album, imageRepair: .ready, processingState: .success)
    Information(missingArtwork: compilation, imageRepair: .ready, processingState: .failure)
  }
}
