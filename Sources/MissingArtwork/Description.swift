//
//  Description.swift
//  MissingArt
//
//  Created by Greg Bolsinga on 4/7/22.
//

import SwiftUI

public struct Description: View {
  let missingArtwork: MissingArtwork

  public init(missingArtwork: MissingArtwork) {
    self.missingArtwork = missingArtwork
  }

  public var body: some View {
    Group {
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
    }
    .padding(.vertical, 4)
  }
}

struct Description_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Description(missingArtwork: MissingArtwork.previewArtworks[0])
      Description(missingArtwork: MissingArtwork.previewArtworks[1])
    }
  }
}
