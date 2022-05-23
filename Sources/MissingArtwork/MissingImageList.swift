//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import SwiftUI

struct MissingImageList: View {
  @EnvironmentObject var model: Model

  let missingArtwork: MissingArtwork
  let token: String

  struct IdentifiableURL: Identifiable {
    public let url: URL
    public var id: URL { return url }
  }

  private var identifiableURLs: [IdentifiableURL]? {
    model.missingArtworkURLs[missingArtwork]
      .map { $0.map { IdentifiableURL(url: $0) } }
  }

  @ViewBuilder private var progressOverlay: some View {
    if identifiableURLs == nil {
      ProgressView()
    } else if let identifiableURLs = identifiableURLs, identifiableURLs.count == 0 {
      Text("No image for \(missingArtwork.description)")
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
      .task {
        await model.fetchImageURLs(missingArtwork: missingArtwork, token: token)
      }
  }
}

struct MissingImageList_Previews: PreviewProvider {
  static var previews: some View {
    let model = Model.preview
    Group {
      MissingImageList(missingArtwork: model.missingArtworks.first!, token: "")
      MissingImageList(missingArtwork: model.missingArtworks.last!, token: "")
    }
    .environmentObject(model)
  }
}
