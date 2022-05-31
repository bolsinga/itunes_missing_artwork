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

  @ViewBuilder private var progressOverlay: some View {
    if identifiableURLs == nil {
      ProgressView()
    } else if let identifiableURLs = identifiableURLs, identifiableURLs.count == 0 {
      Text("No image for \(missingArtwork.description)")
        .textSelection(.enabled)
    }
  }

  var body: some View {
    List(self.identifiableURLs ?? []) { item in
      AsyncImage(url: item.url) { image in
        image
      } placeholder: {
        ProgressView()
      }
    }.overlay(progressOverlay)
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
