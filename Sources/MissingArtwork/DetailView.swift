//
//  DetailView.swift
//
//
//  Created by Greg Bolsinga on 1/27/23.
//

import SwiftUI

struct DetailView: View {
  let missingArtworks: [MissingArtwork]
  var model: ArtworksModel
  let selectedArtworks: Set<MissingArtwork>
  @Binding var selectedArtworkImages: [MissingArtwork: ArtworkLoadingImage]
  @Binding var processingStates: [MissingArtwork: ProcessingState]
  let sortOrder: SortOrder
  @State private var artworkLoadingStates: [MissingArtwork: MissingArtworkLoadingImageModel] =
    [:]

  private var missingArtworksIsEmpty: Bool {
    missingArtworks.isEmpty
  }

  private var missingArtworkIsSelectable: Bool {
    !missingArtworksIsEmpty
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
          loadingState: $artworkLoadingStates[artwork].defaultValue(
            MissingArtwork.createArtworkLoadingImageModel()),
          selectedArtworkImage: $selectedArtworkImages[artwork],
          processingState: $processingStates[artwork].defaultValue(.none))
      } else {
        InformationListView(
          missingArtworks: Array(selectedArtworks).sorted(by: sortOrder),
          missingArtworkWithImages: Set(
            selectedArtworks.filter { selectedArtworkImages[$0] != nil }.map { $0 }
          ).union(missingArtworks.filter { $0.availability == .some }),
          missingArtworksNoImageFound: Set(
            selectedArtworks.filter { artworkLoadingStates[$0]?.isError ?? false }),
          processingStates: $processingStates)
      }
    }
  }
}

#Preview("No Missing Artworks") {
  DetailView(
    missingArtworks: [],
    model: ArtworksModel(),
    selectedArtworks: [],
    selectedArtworkImages: .constant([:]),
    processingStates: .constant([:]),
    sortOrder: .ascending
  )
  .frame(width: 300, height: 300)
}

#Preview("Missing Artwork - No Selection") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  DetailView(
    missingArtworks: [missingArtwork],
    model: ArtworksModel(),
    selectedArtworks: [],
    selectedArtworkImages: .constant([:]),
    processingStates: .constant([:]),
    sortOrder: .ascending
  )
  .frame(width: 300, height: 300)
}

#Preview("Missing Artwork - Selected") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  DetailView(
    missingArtworks: [missingArtwork],
    model: ArtworksModel(),
    selectedArtworks: [missingArtwork],
    selectedArtworkImages: .constant([:]),
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
    model: ArtworksModel(),
    selectedArtworks: Set(missingArtworks),
    selectedArtworkImages: .constant([:]),
    processingStates: .constant([:]),
    sortOrder: .ascending
  )
  .frame(width: 300, height: 300)
}
