//
//  Description.swift
//  MissingArt
//
//  Created by Greg Bolsinga on 4/7/22.
//

import SwiftUI

public struct Description: View {
  let missingArtwork: MissingArtwork
  let availability: ArtworkAvailability

  public init(missingArtwork: MissingArtwork, availability: ArtworkAvailability) {
    self.missingArtwork = missingArtwork
    self.availability = availability
  }

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
      Spacer()
      switch availability {
      case .some:
        Image(systemName: "questionmark.square.dashed")
      case .none:
        EmptyView()
      }
    }
    .padding(.vertical, 4)
  }
}

struct Description_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Description(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House"), availability: .none)
      Description(
        missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House"), availability: .some)
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1"),
        availability: .none)
      Description(
        missingArtwork: MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1"),
        availability: .some)
    }
  }
}
