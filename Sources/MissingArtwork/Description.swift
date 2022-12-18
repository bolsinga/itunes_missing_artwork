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
  let availability: ArtworkAvailability

  @Binding var processingState: ProcessingState

  public var body: some View {
    HStack {
      switch missingArtwork {
      case .ArtistAlbum(let artist, let album):
        VStack(alignment: .leading) {
          Text(album)
            .font(.headline)
          Text(artist)
            .font(.caption)

        }
      case .CompilationAlbum(let album):
        HStack {
          Text(album)
            .font(.headline)
          Image(systemName: "square.stack")
        }
      }
      switch processingState {
      case .none:
        EmptyView()
      case .processing:
        Image(systemName: "gearshape.circle")
      case .success:
        Image(systemName: "checkmark.circle")
          .foregroundColor(.green)
      case .failure:
        Image(systemName: "circle.slash")
          .foregroundColor(.red)
      }
      Spacer()
      switch availability {
      case .some:
        Image(systemName: "questionmark.square.dashed")
      case .none:
        EmptyView()
      case .unknown:
        Image(systemName: "questionmark.square.dashed").foregroundColor(.red)
      }
    }
    .padding(.vertical, 4)
  }
}

struct Description_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Description(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House"), availability: .none,
        processingState: .constant(Description.ProcessingState.none))
      Description(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House"), availability: .some,
        processingState: .constant(Description.ProcessingState.processing))
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1"),
        availability: .none, processingState: .constant(Description.ProcessingState.success))
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1"),
        availability: .some, processingState: .constant(Description.ProcessingState.failure))
    }
  }
}
