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

  var body: some View {
    Group {
      if let identifiableURLs = self.identifiableURLs, identifiableURLs.count > 0 {
        List {
          ForEach(identifiableURLs) {
            AsyncImage(url: $0.url)
          }
        }
      } else {
        Text("No image for \(missingArtwork.description)")
      }
    }.task {
      await model.fetchImageURLs(missingArtwork: missingArtwork, token: token)
    }
  }
}

struct MissingImageList_Previews: PreviewProvider {
  static var previews: some View {
    MissingImageList(
      missingArtwork: MissingArtwork.ArtistAlbum("The Stooges", "Fun House"), token: "")
  }
}
