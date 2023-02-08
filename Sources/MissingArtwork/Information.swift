//
//  Information.swift
//
//
//  Created by Greg Bolsinga on 2/6/23.
//

import SwiftUI

struct Information: View {
  let missingArtwork: MissingArtwork
  let imageFound: Bool
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

  @ViewBuilder private var imageFoundView: some View {
    imageFound
      ? Text(
        "Image Ready", bundle: .module,
        comment: "Help string shown when image is ready for fixing.")
      : Text(
        "No Image Selected", bundle: .module,
        comment: "Help string shown when no image has been selected for fixing.")
  }

  var body: some View {
    HStack {
      nameView
      Spacer()
      imageFoundView
      processingState.representingView
    }
    .padding(.all)
  }
}

struct Information_Previews: PreviewProvider {
  static var previews: some View {
    let album = MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none)
    let compilation = MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .some)

    Information(missingArtwork: album, imageFound: true, processingState: .none)
    Information(missingArtwork: compilation, imageFound: false, processingState: .processing)
    Information(missingArtwork: album, imageFound: true, processingState: .success)
    Information(missingArtwork: compilation, imageFound: false, processingState: .failure)
  }
}
