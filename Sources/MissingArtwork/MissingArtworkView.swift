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
  @State private var loadingState: LoadingState<[MissingArtwork]> = .loading

  @State private var missingArtworks: [MissingArtwork] = []

  @Binding var processingStates: [MissingArtwork: Description.ProcessingState]

  public typealias ImageContextMenuBuilder = ([(missingArtwork: MissingArtwork, image: NSImage?)])
    -> Content

  @ViewBuilder let imageContextMenuBuilder: ImageContextMenuBuilder

  public init(
    @ViewBuilder imageContextMenuBuilder: @escaping ImageContextMenuBuilder,
    processingStates: Binding<[MissingArtwork: Description.ProcessingState]>
  ) {
    self.imageContextMenuBuilder = imageContextMenuBuilder
    self._processingStates = processingStates  // Note this for assigning a Binding<T> to a wrapped property.
  }

  @MainActor private func reportError(_ error: FetchError) {
    loadingState = .error(error)
    debugPrint("Unable to fetch missing artworks: \(error.localizedDescription)")
  }

  public var body: some View {
    DescriptionList(
      imageContextMenuBuilder: imageContextMenuBuilder,
      missingArtworks: missingArtworks,
      showProgressOverlay: .constant(loadingState.isLoading),
      processingStates: $processingStates
    )
    .alert(
      isPresented: .constant(loadingState.isError), error: loadingState.currentError,
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
      guard missingArtworks.isEmpty else {
        loadingState = .loaded(missingArtworks)
        return
      }

      loadingState = .loading

      do {
        missingArtworks = try await fetchMissingArtworks()

        loadingState = .loaded(missingArtworks)
      } catch let error as NSError {
        reportError(.cannotFetchMissingArtwork(error))
      } catch {
        reportError(.unknownError(error))
      }
    }
    .musicKitAuthorizationSheet()
  }

  func fetchMissingArtworks() async throws -> [MissingArtwork] {
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
