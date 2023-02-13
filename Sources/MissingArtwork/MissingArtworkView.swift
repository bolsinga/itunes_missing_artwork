//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import MusicKit
import SwiftUI

public struct MissingArtworkView<
  NoArtworkContextMenuContent: View, PartialArtworkContextMenuContent: View
>: View {
  @State private var loadingState: LoadingState<[MissingArtwork]> = .idle

  @Binding var processingStates: [MissingArtwork: ProcessingState]

  public typealias NoArtworkContextMenuBuilder = (
    [(missingArtwork: MissingArtwork, image: NSImage)]
  ) -> NoArtworkContextMenuContent
  public typealias PartialArtworkContextMenuBuilder = ([MissingArtwork]) ->
    PartialArtworkContextMenuContent

  @ViewBuilder let noArtworkContextMenuBuilder: NoArtworkContextMenuBuilder
  @ViewBuilder let partialArtworkContextMenuBuilder: PartialArtworkContextMenuBuilder

  public init(
    @ViewBuilder noArtworkContextMenuBuilder: @escaping NoArtworkContextMenuBuilder,
    @ViewBuilder partialArtworkContextMenuBuilder: @escaping PartialArtworkContextMenuBuilder,
    processingStates: Binding<[MissingArtwork: ProcessingState]>
  ) {
    self.noArtworkContextMenuBuilder = noArtworkContextMenuBuilder
    self.partialArtworkContextMenuBuilder = partialArtworkContextMenuBuilder
    self._processingStates = processingStates  // Note this for assigning a Binding<T> to a wrapped property.
  }

  public var body: some View {
    DescriptionList(
      noArtworkContextMenuBuilder: noArtworkContextMenuBuilder,
      partialArtworkContextMenuBuilder: partialArtworkContextMenuBuilder,
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
      noArtworkContextMenuBuilder: { items in
        EmptyView()
      },
      partialArtworkContextMenuBuilder: { items in
        EmptyView()
      }, processingStates: .constant([:]))
  }
}
