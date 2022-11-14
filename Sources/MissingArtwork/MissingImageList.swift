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

  @Binding var selectedArtwork: Artwork?

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack {
          ForEach(self.artworks ?? []) { artwork in
            MissingArtworkImage(artwork: artwork, width: proxy.size.width)
              .onTapGesture { selectedArtwork = artwork }
              .border(.selection, width: selectedArtwork == artwork ? 2.0 : 0)
          }
        }
      }
    }
  }
}

struct MissingImageList_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MissingImageList(
        artworks: .constant([]),
        selectedArtwork: .constant(nil))
    }
  }
}
