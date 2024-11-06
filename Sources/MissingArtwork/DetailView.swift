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

#Preview {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)

  DetailView(
    missingArtworks: [],
    model: ArtworksModel(),
    selectedArtworks: [],
    selectedArtworkImages: .constant([:]),
    processingStates: .constant([:]),
    sortOrder: .ascending)
}
#Preview {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  DetailView(
    missingArtworks: [missingArtwork],
    model: ArtworksModel(),
    selectedArtworks: [],
    selectedArtworkImages: .constant([:]),
    processingStates: .constant([missingArtwork: .none]),
    sortOrder: .ascending)
}
#Preview {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  DetailView(
    missingArtworks: [missingArtwork],
    model: ArtworksModel(),
    selectedArtworks: [missingArtwork],
    selectedArtworkImages: .constant([:]),
    processingStates: .constant([missingArtwork: .none]),
    sortOrder: .ascending)
}
#Preview {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  DetailView(
    missingArtworks: [missingArtwork],
    model: ArtworksModel(),
    selectedArtworks: [missingArtwork],
    selectedArtworkImages: .constant([:]),
    processingStates: .constant([missingArtwork: .none]),
    sortOrder: .ascending)
}
