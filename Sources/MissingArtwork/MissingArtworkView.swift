//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import SwiftUI

public struct MissingArtworkView: View {
  @State private var loadingState = MissingArtwork.createModel()
  @State private var model = ArtworksModel()

  @Binding var processingStates: [MissingArtwork: ProcessingState]

  @State var isMusicKitAuthorized: Bool = false

  public init(processingStates: Binding<[MissingArtwork: ProcessingState]>) {
    self._processingStates = processingStates
  }

  public var body: some View {
    DescriptionList(
      loadingState: loadingState,
      processingStates: $processingStates, model: model
    )
    .alert(
      isPresented: .constant(loadingState.isError), error: loadingState.currentError,
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
    .task(id: isMusicKitAuthorized) {
      if isMusicKitAuthorized {
        await loadingState.load()
      }
    }
    .musicKitAuthorizationSheet(isAuthorized: $isMusicKitAuthorized)
  }
}

#Preview {
  MissingArtworkView(processingStates: .constant([:]))
}
