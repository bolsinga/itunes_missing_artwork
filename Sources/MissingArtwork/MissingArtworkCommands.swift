//
//  MissingArtworkCommands.swift
//
//
//  Created by Greg Bolsinga on 3/1/23.
//

import SwiftUI

public struct MissingArtworkCommands<
  NoArtworkContextMenuContent: View, PartialArtworkContextMenuContent: View
>: Commands {

  @FocusedBinding(\.partialArtworks) var partialArtworks
  @FocusedBinding(\.noArtworks) var noArtworks

  public typealias NoArtworkContextMenuBuilder = (
    [(missingArtwork: MissingArtwork, image: PlatformImage)]
  ) -> NoArtworkContextMenuContent
  public typealias PartialArtworkContextMenuBuilder = ([MissingArtwork]) ->
    PartialArtworkContextMenuContent

  @ViewBuilder let noArtworkContextMenuBuilder: NoArtworkContextMenuBuilder
  @ViewBuilder let partialArtworkContextMenuBuilder: PartialArtworkContextMenuBuilder

  public init(
    @ViewBuilder noArtworkContextMenuBuilder: @escaping NoArtworkContextMenuBuilder,
    @ViewBuilder partialArtworkContextMenuBuilder: @escaping PartialArtworkContextMenuBuilder
  ) {
    self.noArtworkContextMenuBuilder = noArtworkContextMenuBuilder
    self.partialArtworkContextMenuBuilder = partialArtworkContextMenuBuilder
  }

  public var body: some Commands {
    CommandMenu(Text("Repair", bundle: .module, comment: "Command Menu for repairing artwork")) {
      Menu {
        let noArtworkWithImages = noArtworks ?? []
        if noArtworkWithImages.isEmpty {
          Text(
            "No Images Selected", bundle: .module,
            comment:
              "Shown when context menu is being shown for No Artwork images and no artwork image has been selected."
          )
        } else {
          self.noArtworkContextMenuBuilder(noArtworkWithImages)
        }
      } label: {
        Text(
          "No Artwork", bundle: .module,
          comment: "Label for the context menu grouping No Artwork actions.")
      }
      Menu {
        self.partialArtworkContextMenuBuilder(partialArtworks ?? [])
      } label: {
        Text(
          "Partial Artwork", bundle: .module,
          comment: "Label for the context menu grouping Partial Artwork actions.")
      }
    }
  }
}

private struct PartialArtworksKey: FocusedValueKey {
  typealias Value = Binding<[MissingArtwork]>
}

private struct NoArtworksKey: FocusedValueKey {
  typealias Value = Binding<[(MissingArtwork, PlatformImage)]>
}

extension FocusedValues {
  var partialArtworks: Binding<[MissingArtwork]>? {
    get { self[PartialArtworksKey.self] }
    set { self[PartialArtworksKey.self] = newValue }
  }

  var noArtworks: Binding<[(MissingArtwork, PlatformImage)]>? {
    get { self[NoArtworksKey.self] }
    set { self[NoArtworksKey.self] = newValue }
  }
}
