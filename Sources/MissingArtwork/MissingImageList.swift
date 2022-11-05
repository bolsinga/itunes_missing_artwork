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
        artworks: .constant([]))
    }
  }
}
