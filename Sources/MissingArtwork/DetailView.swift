//
//  DetailView.swift
//
//
//  Created by Greg Bolsinga on 1/27/23.
//

import AppKit
import MusicKit
import SwiftUI

struct DetailView: View {
  @Binding var loadingState: LoadingState<[MissingArtwork]>
  @Binding var artworkLoadingStates:
    [MissingArtwork: LoadingState<[(Artwork, LoadingState<NSImage>)]>]
  @Binding var selectedArtworks: Set<MissingArtwork>
  @Binding var selectedArtworkImages: [MissingArtwork: NSImage]

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
      MissingImageList(
        missingArtwork: selectedArtworks.first!,
        loadingState: $artworkLoadingStates[selectedArtworks.first!].defaultValue(.idle),
        selectedArtworkImage: $selectedArtworkImages[selectedArtworks.first!]
      )
    }
  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)

    DetailView(
      loadingState: .constant(.loading),
      artworkLoadingStates: .constant([:]),
      selectedArtworks: .constant([]),
      selectedArtworkImages: .constant([:]))

    DetailView(
      loadingState: .constant(.loaded([missingArtwork])),
      artworkLoadingStates: .constant([missingArtwork: .loading]),
      selectedArtworks: .constant([]),
      selectedArtworkImages: .constant([:]))

    DetailView(
      loadingState: .constant(.loaded([missingArtwork])),
      artworkLoadingStates: .constant([missingArtwork: .loading]),
      selectedArtworks: .constant([missingArtwork]),
      selectedArtworkImages: .constant([:]))

    DetailView(
      loadingState: .constant(.loaded([missingArtwork])),
      artworkLoadingStates: .constant([missingArtwork: .loaded([])]),
      selectedArtworks: .constant([missingArtwork]),
      selectedArtworkImages: .constant([:]))
  }
}
