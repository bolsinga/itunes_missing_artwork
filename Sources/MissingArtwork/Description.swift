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

  @ViewBuilder private var processedStateView: some View {
    if case .processing = processingState {
      Image(systemName: "gearshape.circle")
        .imageScale(.large)
        .help(
          Text(
            "Fixing Album", bundle: .module,
            comment: "Help string shown when album artwork is in the process of being fixed."))
    } else if case .success = processingState {
      Image(systemName: "checkmark.circle")
        .imageScale(.large)
        .foregroundColor(.green)
        .help(
          Text(
            "Fixed Album", bundle: .module,
            comment: "Help string shown when album artwork has been fixed."))
    } else if case .failure = processingState {
      Image(systemName: "circle.slash")
        .imageScale(.large)
        .foregroundColor(.red)
        .help(
          Text(
            "Unable to Fix Album", bundle: .module,
            comment: "Help string shown when album artwork failed to be fixed."))
    }
  }

  @ViewBuilder private var availabilityImage: some View {
    if case .some = missingArtwork.availability {
      Image(systemName: "questionmark.square.dashed")
        .imageScale(.large)
        .help(
          Text(
            "Partial Artwork", bundle: .module,
            comment: "Help string shown when album artwork is partially set."))
    } else if case .unknown = missingArtwork.availability {
      Image(systemName: "questionmark.square.dashed").foregroundColor(.red)
        .imageScale(.large)
        .help(
          Text(
            "No Artwork", bundle: .module,
            comment: "Help string shown when album artwork does not exist and must be searched for."
          ))
    }
  }

  public var body: some View {
    HStack {
      nameView
      processedStateView
      Spacer()
      availabilityImage
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
