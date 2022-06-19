//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import MusicKit
import SwiftUI

extension Artwork: Identifiable {
  public var id: Artwork { self }
}

struct MissingImageList: View {
  let missingArtwork: MissingArtwork
  @Binding var artworks: [Artwork]?

  var body: some View {
    GeometryReader { proxy in
      List(self.artworks ?? []) { artwork in
        ArtworkImage(artwork, width: proxy.size.width)
      }
    }
  }
}

struct MissingImageList_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MissingImageList(
        missingArtwork: MissingArtwork.previewArtworks.first!,
        artworks: .constant([]))
      MissingImageList(
        missingArtwork: MissingArtwork.previewArtworks.last!,
        artworks: .constant([]))
    }
  }
}
