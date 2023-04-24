//
//  Description.swift
//  MissingArt
//
//  Created by Greg Bolsinga on 4/7/22.
//

import SwiftUI

public struct Description: View {
  let missingArtwork: MissingArtwork

  @Binding var processingState: ProcessingState

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
        Image(systemName: "square.stack")
          .imageScale(.large)
      }
    }
  }

  public var body: some View {
    HStack {
      nameView
      processingState.representingView
      Spacer()
      missingArtwork.availability.representingView
    }
    .padding(.vertical, 4)
  }
}

struct Description_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Description(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
        processingState: .constant(ProcessingState.none))
      Description(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
        processingState: .constant(ProcessingState.processing))
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum(
          "Beleza Tropical: Brazil Classics 1", .none),
        processingState: .constant(ProcessingState.success))
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum(
          "Beleza Tropical: Brazil Classics 1", .some),
        processingState: .constant(ProcessingState.failure))
    }
  }
}
