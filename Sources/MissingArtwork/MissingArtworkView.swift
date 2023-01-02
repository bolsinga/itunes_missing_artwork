//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import MusicKit
import SwiftUI

private enum FetchError: Error {
  case cannotFetchMissingArtwork(NSError)
  case unknownError(Error)
}

extension FetchError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .cannotFetchMissingArtwork(let error):
      return "iTunes Library unable to find missing artwork: \(error.localizedDescription)"
    case .unknownError(let error):
      return "iTunes Library unknown error: \(error)"
    }
  }
  fileprivate var recoverySuggestion: String? {
    "iTunes was unable to find any missing artwork to fix."
  }
}

public struct MissingArtworkView<Content: View>: View {
  @State private var showProgressOverlay: Bool = true

  @State private var fetchError: FetchError?

  @State private var missingArtworks: [(MissingArtwork, ArtworkAvailability)] = []

  @Binding var processingStates: [MissingArtwork: Description.ProcessingState]

  public typealias MissingImage = (
    missingArtwork: MissingArtwork, availability: ArtworkAvailability, image: NSImage?
  )
  public typealias ImageContextMenuBuilder = ([MissingImage]) -> Content

  @ViewBuilder let imageContextMenuBuilder: ImageContextMenuBuilder

  public init(
    @ViewBuilder imageContextMenuBuilder: @escaping ImageContextMenuBuilder,
    processingStates: Binding<[MissingArtwork: Description.ProcessingState]>
  ) {
    self.imageContextMenuBuilder = imageContextMenuBuilder
    self._processingStates = processingStates  // Note this for assigning a Binding<T> to a wrapped property.
  }

  @MainActor private func reportError(_ error: FetchError) {
    fetchError = error
    debugPrint("Unable to fetch missing artworks: \(String(describing: fetchError))")
  }

  public var body: some View {
    DescriptionList(
      imageContextMenuBuilder: imageContextMenuBuilder,
      missingArtworks: $missingArtworks,
      showProgressOverlay: $showProgressOverlay,
      processingStates: $processingStates
    )
    .alert(
      isPresented: .constant(fetchError != nil), error: fetchError,
      actions: { error in
        Button("Quit", role: .destructive) {
          NSApplication.shared.terminate(nil)
        }
      },
      message: { error in
        Text(error.recoverySuggestion ?? "")
      }
    )
    .task {
      showProgressOverlay = true

      guard missingArtworks.isEmpty else {
        return
      }

      do {
        missingArtworks = try await fetchMissingArtworks()
      } catch let error as NSError {
        reportError(.cannotFetchMissingArtwork(error))
      } catch {
        reportError(.unknownError(error))
      }
      showProgressOverlay = false
    }
    .musicKitAuthorizationSheet()
  }

  func fetchMissingArtworks() async throws -> [(MissingArtwork, ArtworkAvailability)] {
    async let missingArtworks = try MissingArtwork.gatherMissingArtwork()
    return try await missingArtworks
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView(
      imageContextMenuBuilder: { items in
        Button("1") {}
        Button("2") {}
      }, processingStates: .constant([:]))
  }
}
