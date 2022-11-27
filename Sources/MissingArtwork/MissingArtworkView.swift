//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import MusicKit
import SwiftUI

public struct MissingArtworkView<Content: View>: View, ArtworksFetcher {
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

  @State private var missingArtworks: [(MissingArtwork, ArtworkAvailability)] = []

  public typealias ImageContextMenuBuilder = (MissingArtwork) -> Content

  @ViewBuilder let imageContextMenuBuilder: ImageContextMenuBuilder

  public init(@ViewBuilder imageContextMenuBuilder: @escaping ImageContextMenuBuilder) {
    self.imageContextMenuBuilder = imageContextMenuBuilder
  }

  public var body: some View {
    DescriptionList(
      fetcher: self,
      imageContextMenuBuilder: imageContextMenuBuilder,
      missingArtworks: $missingArtworks,
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
        missingArtworks = try await fetchMissingArtworks()

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

  func fetchMissingArtworks() async throws -> [(MissingArtwork, ArtworkAvailability)] {
    async let missingArtworks = try MissingArtwork.gatherMissingArtwork()
    return try await missingArtworks
  }

  func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws -> [Artwork] {
    var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
    searchRequest.limit = 2
    let searchResponse = try await searchRequest.response()
    return searchResponse.albums.compactMap(\.artwork)
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView(imageContextMenuBuilder: { missingArtwork in
      Button("1") {}
      Button("2") {}
    })
  }
}
