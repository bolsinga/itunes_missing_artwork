//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import SwiftUI

public struct MissingArtworkView: View, ImageURLFetcher {
  struct FetchError: LocalizedError {
    let nsError: NSError

    var errorDescription: String? {
      nsError.localizedDescription
    }

    var failureReason: String? {
      nsError.localizedFailureReason
    }

    var recoverySuggestion: String? {
      nsError.localizedRecoverySuggestion
    }
  }

  @State private var showProgressOverlay: Bool = true
  @State private var showNoMissingArtworkFound: Bool = false

  @State private var showFetchErrorAlert: Bool = false
  @State private var fetchError: FetchError?

  @StateObject private var model = Model()

  public init() {}

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
    .alert(
      isPresented: $showFetchErrorAlert, error: fetchError,
      actions: { error in
        Button("Quit", role: .destructive) {
          NSApplication.shared.terminate(nil)
        }
      }, message: { error in Text("The iTunes Library has found an error when loading.") }
    )
    .task {
      showProgressOverlay = true
      do {
        try await model.fetchMissingArtworks()

        showNoMissingArtworkFound = model.missingArtworks.isEmpty
      } catch let error as NSError {
        showFetchErrorAlert = true

        fetchError = FetchError(nsError: error)
        debugPrint("Unable to fetch missing artworks: \(error)")
      }
      showProgressOverlay = false
    }
    .musicKitAuthorizationSheet()
  }

  func fetchImages(missingArtwork: MissingArtwork, term: String) async throws {
    try await model.fetchImageURLs(
      missingArtwork: missingArtwork, term: term)
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView()
  }
}
