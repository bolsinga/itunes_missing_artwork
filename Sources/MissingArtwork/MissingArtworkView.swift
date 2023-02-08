//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import MusicKit
import SwiftUI

public struct MissingArtworkView<Content: View>: View {
  @State private var loadingState: LoadingState<[MissingArtwork]> = .idle

  @Binding var processingStates: [MissingArtwork: ProcessingState]

  public typealias ImageContextMenuBuilder = ([(missingArtwork: MissingArtwork, image: NSImage?)])
    -> Content

  @ViewBuilder let imageContextMenuBuilder: ImageContextMenuBuilder

  public init(
    @ViewBuilder imageContextMenuBuilder: @escaping ImageContextMenuBuilder,
    processingStates: Binding<[MissingArtwork: ProcessingState]>
  ) {
    self.imageContextMenuBuilder = imageContextMenuBuilder
    self._processingStates = processingStates  // Note this for assigning a Binding<T> to a wrapped property.
  }

  public var body: some View {
    DescriptionList(
      imageContextMenuBuilder: imageContextMenuBuilder,
      loadingState: $loadingState,
      processingStates: $processingStates
    )
    .alert(
      isPresented: .constant(loadingState.isError), error: loadingState.currentError,
      actions: { error in
        Button(role: .destructive) {
          NSApplication.shared.terminate(nil)
        } label: {
          Text("Quit", bundle: .module, comment: "Button shown when an unrecoverable error occurs.")
        }
      },
      message: { error in
        Text(error.recoverySuggestion ?? "")
      }
    )
    .task {
      await loadingState.load()
    }
    .musicKitAuthorizationSheet()
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView(
      imageContextMenuBuilder: { items in
        EmptyView()
      }, processingStates: .constant([:]))
  }
}
