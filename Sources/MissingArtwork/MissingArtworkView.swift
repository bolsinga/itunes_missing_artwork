//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import SwiftUI

public struct MissingArtworkView: View, ImageURLFetcher {
  let token: String

  @StateObject private var model = Model()

  public init(token: String) {
    self.token = token
  }

  public var body: some View {
    DescriptionList(
      fetcher: self,
      missingArtworks: $model.missingArtworks,
      missingArtworkURLs: $model.missingArtworkURLs
    )
    .task {
      await model.fetchMissingArtworks(token: token)
    }
  }

  func fetchImages(missingArtwork: MissingArtwork, term: String) async {
    await model.fetchImageURLs(
      missingArtwork: missingArtwork, term: term, token: token)
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView(token: "")
  }
}
