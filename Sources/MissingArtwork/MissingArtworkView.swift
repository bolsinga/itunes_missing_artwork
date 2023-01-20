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

  public var body: some View {
    DescriptionList(
      imageContextMenuBuilder: imageContextMenuBuilder,
      missingArtworks: loadingState.value,
      showProgressOverlay: .constant(loadingState.isIdleOrLoading),
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
      await loadingState.load()
    }
    .musicKitAuthorizationSheet()
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
