//
//  Description.swift
//  MissingArt
//
//  Created by Greg Bolsinga on 4/7/22.
//

import SwiftUI

public struct Description: View {
  public enum ProcessingState {
    case none  // no action has been taken
    case processing  // the action is processing
    case success  // the action has succeeded
    case failure  // the action has failed.
  }

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
      }
    }
  }

  @ViewBuilder private var processedStateView: some View {
    if case .processing = processingState {
      Image(systemName: "gearshape.circle")
    } else if case .success = processingState {
      Image(systemName: "checkmark.circle")
        .foregroundColor(.green)
    } else if case .failure = processingState {
      Image(systemName: "circle.slash")
        .foregroundColor(.red)
    }
  }

  @ViewBuilder private var availabilityImage: some View {
    if case .some = missingArtwork.availability {
      Image(systemName: "questionmark.square.dashed")
    } else if case .unknown = missingArtwork.availability {
      Image(systemName: "questionmark.square.dashed").foregroundColor(.red)
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
        processingState: .constant(Description.ProcessingState.none))
      Description(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some),
        processingState: .constant(Description.ProcessingState.processing))
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum(
          "Beleza Tropical: Brazil Classics 1", .none),
        processingState: .constant(Description.ProcessingState.success))
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum(
          "Beleza Tropical: Brazil Classics 1", .some),
        processingState: .constant(Description.ProcessingState.failure))
    }
  }
}
