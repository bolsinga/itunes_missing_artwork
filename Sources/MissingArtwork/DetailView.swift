//
//  DetailView.swift
//
//
//  Created by Greg Bolsinga on 1/27/23.
//

import SwiftUI

struct DetailView<C: ArtworkProtocol>: View {
  let missingArtworks: [MissingArtwork]
  var model: MissingArtworksModel<C>
  let selectedArtworks: Set<MissingArtwork>
  @Binding var selectedArtwork: C?
  @Binding var processingStates: [MissingArtwork: ProcessingState]
  let sortOrder: SortOrder

  private var missingArtworksIsEmpty: Bool {
    missingArtworks.isEmpty
  }

  private var missingArtworkIsSelectable: Bool {
    !missingArtworksIsEmpty
  }

  private var selectedArtworksWithImages: Set<MissingArtwork> {
    Set(selectedArtworks.filter { $0.availability == .some }).intersection(
      model.missingArtworksWithPlatformImages)
  }

  private var selectedArtworksWithErrors: Set<MissingArtwork> {
    Set(selectedArtworks).intersection(model.missingArtworksWithErrors)
  }

  var body: some View {
    if selectedArtworks.isEmpty {
      if missingArtworkIsSelectable {
        MissingArtworkTypeChart(missingArtworks: missingArtworks)
      } else {
        Text(
          "No Missing Artwork To Display.", bundle: .module,
          comment: "Displayed when DetailView has no missing artworks to display.")
      }
    } else {
      if selectedArtworks.count == 1, let artwork = selectedArtworks.first {
        SingleSelectedMissingArtworkView(
          missingArtwork: artwork, model: model,
          selectedArtwork: $selectedArtwork,
          processingState: $processingStates[artwork].defaultValue(.none))
      } else {
        InformationListView(
          missingArtworks: Array(selectedArtworks).sorted(by: sortOrder),
          missingArtworkWithImages: selectedArtworksWithImages,
          missingArtworksNoImageFound: selectedArtworksWithErrors,
          processingStates: $processingStates)
      }
    }
  }
}

#Preview("No Missing Artworks") {
  DetailView(
    missingArtworks: [],
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtworks: [],
    selectedArtwork: .constant(nil),
    processingStates: .constant([:]),
    sortOrder: .ascending
  )
  .frame(width: 300, height: 300)
}

#Preview("Missing Artwork - No Selection") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  DetailView(
    missingArtworks: [missingArtwork],
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtworks: [],
    selectedArtwork: .constant(nil),
    processingStates: .constant([:]),
    sortOrder: .ascending
  )
  .frame(width: 300, height: 300)
}

#Preview("Missing Artwork - Selected") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  DetailView(
    missingArtworks: [missingArtwork],
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtworks: [missingArtwork],
    selectedArtwork: .constant(nil),
    processingStates: .constant([:]),
    sortOrder: .ascending
  )
  .frame(width: 300, height: 300)
}

#Preview("Two Missing Artwork - Both Selected") {
  let missingArtworks = [
    MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
    MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none),
  ]
  DetailView(
    missingArtworks: missingArtworks,
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtworks: Set(missingArtworks),
    selectedArtwork: .constant(nil),
    processingStates: .constant([:]),
    sortOrder: .ascending
  )
  .frame(width: 300, height: 300)
}
