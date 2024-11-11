//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import SwiftUI

public struct MissingArtworkView: View {
  @State private var model = ArtworksModel()

  @Binding var processingStates: [MissingArtwork: ProcessingState]

  @State private var isMusicKitAuthorized: Bool = false
  @State private var error: Error?
  @State private var missingArtworksLoading: Bool = true

  public init(processingStates: Binding<[MissingArtwork: ProcessingState]>) {
    self._processingStates = processingStates
  }

  private var currentError: WrappedLocalizedError? {
    guard let error else { return nil }
    return WrappedLocalizedError.wrapError(error: error)
  }

  public var body: some View {
    DescriptionList(
      missingArtworksLoading: missingArtworksLoading,
      processingStates: $processingStates, model: model
    )
    .alert(
      isPresented: .constant(error != nil), error: currentError,
      actions: { error in
        Button {
        } label: {
          Text("OK", bundle: .module, comment: "Button shown when an unrecoverable error occurs.")
        }
      },
      message: { error in
        Text(error.recoverySuggestion ?? "")
      }
    )
    .task {
      if isMusicKitAuthorized {
        do {
          try await model.loadMissingArtwork()
        } catch {
          self.error = error
        }
        missingArtworksLoading = false
      }
    }
    .musicKitAuthorizationSheet(isAuthorized: $isMusicKitAuthorized)
  }
}

#Preview {
  MissingArtworkView(processingStates: .constant([:]))
}
