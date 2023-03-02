//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import LoadingState
import MusicKit
import SwiftUI

public struct MissingArtworkView: View {
  @State private var loadingState: LoadingState<[MissingArtwork]> = .idle

  @Binding var processingStates: [MissingArtwork: ProcessingState]

  public init(processingStates: Binding<[MissingArtwork: ProcessingState]>) {
    self._processingStates = processingStates
  }

  public var body: some View {
    DescriptionList(
      loadingState: $loadingState,
      processingStates: $processingStates
    )
    .alert(
      isPresented: .constant(loadingState.isError), error: loadingState.currentError,
      actions: { error in
        Button() {
        } label: {
          Text("OK", bundle: .module, comment: "Button shown when an unrecoverable error occurs.")
        }
      },
      message: { error in
        Text(error.recoverySuggestion ?? "")
      }
    )
    .task {
      await loadingState.load()
    }
    .musicKitAuthorizationSheet(readyToShowSheet: .constant(loadingState.hasMissingArtwork))
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView(processingStates: .constant([:]))
  }
}
