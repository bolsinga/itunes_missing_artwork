//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import SwiftUI

struct MissingImageList: View {
  let missingArtwork: MissingArtwork
  @Binding var urls: [URL]?

  struct IdentifiableURL: Identifiable {
    public let url: URL
    public var id: URL { return url }
  }

  private var identifiableURLs: [IdentifiableURL]? {
    urls.map { $0.map { IdentifiableURL(url: $0) } }
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
        missingArtwork: Model.previewArtworks.first!,
        urls: .constant(Model.previewArtworkURLs.first))
      MissingImageList(
        missingArtwork: Model.previewArtworks.last!,
        urls: .constant(Model.previewArtworkURLs.last))
    }
  }
}
