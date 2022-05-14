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

  struct MissingArtworkIdentifiableURL: Identifiable {
    public var id: URL
  }

  var body: some View {
    Group {
      if let urls = model.missingArtworkURLs[missingArtwork], urls.count > 0 {
        List {
          ForEach(urls) {
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
