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
  @Binding var artworkImages: [ArtworkImage]

  @Binding var selectedArtworkImage: ArtworkImage?

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack {
          ForEach($artworkImages, id: \.artwork) { $artworkImage in
            MissingArtworkImage(artwork: artworkImage.artwork, width: proxy.size.width)
              .onTapGesture { selectedArtworkImage = artworkImage }
              .border(.selection, width: selectedArtworkImage == artworkImage ? 2.0 : 0)
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
        artworkImages: .constant([]),
        selectedArtworkImage: .constant(nil))
    }
  }
}
