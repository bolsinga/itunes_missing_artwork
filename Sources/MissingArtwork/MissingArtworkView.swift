//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import SwiftUI

public struct MissingArtworkView: View, ArtworksFetcher {
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

  @State private var missingArtworks: [MissingArtwork] = []
  @State private var artworks: [MissingArtwork: [URL]] = [:]

  @StateObject private var model = Model()

  public init() {}

  public var body: some View {
    DescriptionList(
      fetcher: self,
      missingArtworks: $missingArtworks,
      artworks: $artworks,
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

      guard missingArtworks.isEmpty else {
        return
      }

      do {
        missingArtworks = try await model.fetchMissingArtworks()

        showNoMissingArtworkFound = missingArtworks.isEmpty
      } catch let error as NSError {
        showFetchErrorAlert = true

        fetchError = FetchError(nsError: error)
        debugPrint("Unable to fetch missing artworks: \(error)")
      }
      showProgressOverlay = false
    }
    .musicKitAuthorizationSheet()
  }

  func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws -> [URL] {
    return try await model.fetchArtworks(missingArtwork: missingArtwork, term: term)
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView()
  }
}
