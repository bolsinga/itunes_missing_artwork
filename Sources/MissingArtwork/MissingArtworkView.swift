//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import SwiftUI

public struct MissingArtworkView: View, ImageURLFetcher {
  let token: String

  @State private var showProgressOverlay: Bool = true
  @State private var showNoMissingArtworkFound: Bool = false

  @StateObject private var model = Model()

  public init(token: String) {
    self.token = token
  }

  public var body: some View {
    DescriptionList(
      fetcher: self,
      missingArtworks: $model.missingArtworks,
      missingArtworkURLs: $model.missingArtworkURLs,
      showProgressOverlay: $showProgressOverlay
    )
    .alert(
      "No Missing Artwork", isPresented: $showNoMissingArtworkFound,
      actions: {
        Button("Quit", role: .destructive) {
          NSApplication.shared.terminate(nil)
        }
      },
      message: {
        Text("The iTunes Library does not have any missing artwork. Enjoy!")
      }
    )
    .task {
      showProgressOverlay = true
      await model.fetchMissingArtworks(token: token)
      showProgressOverlay = false

      showNoMissingArtworkFound = model.missingArtworks.isEmpty
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
