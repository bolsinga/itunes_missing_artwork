//
//  DetailView.swift
//
//
//  Created by Greg Bolsinga on 1/27/23.
//

import AppKit
import LoadingState
import MusicKit
import SwiftUI

struct DetailView: View {
  let loadingState: LoadingState<[MissingArtwork]>
  @Binding var artworkLoadingStates: [MissingArtwork: LoadingState<[ArtworkLoadingImage]>]
  @Binding var selectedArtworks: Set<MissingArtwork>
  @Binding var selectedArtworkImages: [MissingArtwork: ArtworkLoadingImage]
  let processingStates: [MissingArtwork: ProcessingState]
  let sortOrder: SortOrder

  private var missingArtworksIsEmpty: Bool {
    if let missingArtworks = loadingState.value {
      return missingArtworks.isEmpty
    }
    return true
  }

  private var missingArtworkIsSelectable: Bool {
    !loadingState.isIdleOrLoading && !missingArtworksIsEmpty
  }

  private var missingArtworks: [MissingArtwork] {
    if let missingArtworks = loadingState.value {
      return missingArtworks
    }
    return []
  }

  var body: some View {
    if selectedArtworks.isEmpty {
      if missingArtworkIsSelectable {
        MissingArtworkTypeChart(missingArtworks: missingArtworks)
      }
    } else {
      if selectedArtworks.count == 1, let artwork = selectedArtworks.first {
        MissingImageList(
          missingArtwork: artwork,
          loadingState: $artworkLoadingStates[artwork].defaultValue(.idle),
          selectedArtworkImage: $selectedArtworkImages[artwork]
        )
      } else {
        InformationListView(
          missingArtworks: Array(selectedArtworks).sorted(by: sortOrder),
          missingArtworkWithImages: Set(
            selectedArtworks.filter { selectedArtworkImages[$0] != nil }.map { $0 }
          ).union(missingArtworks.filter { $0.availability == .some }),
          processingStates: processingStates)
      }
    }
  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)

    DetailView(
      loadingState: .loading,
      artworkLoadingStates: .constant([:]),
      selectedArtworks: .constant([]),
      selectedArtworkImages: .constant([:]),
      processingStates: [:],
      sortOrder: .ascending)

    DetailView(
      loadingState: .loaded([missingArtwork]),
      artworkLoadingStates: .constant([missingArtwork: .loading]),
      selectedArtworks: .constant([]),
      selectedArtworkImages: .constant([:]),
      processingStates: [missingArtwork: .none],
      sortOrder: .ascending)

    DetailView(
      loadingState: .loaded([missingArtwork]),
      artworkLoadingStates: .constant([missingArtwork: .loading]),
      selectedArtworks: .constant([missingArtwork]),
      selectedArtworkImages: .constant([:]),
      processingStates: [missingArtwork: .none],
      sortOrder: .ascending)

    DetailView(
      loadingState: .loaded([missingArtwork]),
      artworkLoadingStates: .constant([missingArtwork: .loaded([])]),
      selectedArtworks: .constant([missingArtwork]),
      selectedArtworkImages: .constant([:]),
      processingStates: [missingArtwork: .none],
      sortOrder: .ascending)
  }
}
