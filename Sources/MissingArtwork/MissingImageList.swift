//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import MusicKit
import SwiftUI

struct MissingImageList: View {
  let missingArtwork: MissingArtwork
  @Binding var artworks: [Artwork]?

  struct IdentifiableURL: Identifiable {
    public let url: URL
    public var id: URL { return url }
  }

  private var identifiableURLs: [IdentifiableURL]? {
    let urls = artworks.map { $0.compactMap { $0.url(width: $0.maximumWidth, height: $0.maximumHeight) } }
    return urls.map { $0.map { IdentifiableURL(url: $0) } }
  }

  var body: some View {
    List(self.identifiableURLs ?? []) { item in
      AsyncImage(url: item.url) { image in
        image
      } placeholder: {
        ProgressView()
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
