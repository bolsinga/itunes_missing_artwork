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
  @Binding var selectedArtwork: Set<MissingArtwork>
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

  var body: some View {
    if selectedArtwork.isEmpty {
      if missingArtworkIsSelectable {
        Text(
          "Select an Item", bundle: .module,
          comment: "Text shown to tell user to select a missing artwork.")
      }
    } else {
      MissingImageList(
        missingArtwork: selectedArtwork.first!,
        loadingState: $artworkLoadingStates[selectedArtwork.first!].defaultValue(.idle),
        selectedArtworkImage: $selectedArtworkImages[selectedArtwork.first!]
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
      selectedArtwork: .constant([]),
      selectedArtworkImages: .constant([:]))

    DetailView(
      loadingState: .constant(.loaded([missingArtwork])),
      artworkLoadingStates: .constant([missingArtwork: .loading]),
      selectedArtwork: .constant([]),
      selectedArtworkImages: .constant([:]))

    DetailView(
      loadingState: .constant(.loaded([missingArtwork])),
      artworkLoadingStates: .constant([missingArtwork: .loading]),
      selectedArtwork: .constant([missingArtwork]),
      selectedArtworkImages: .constant([:]))

    DetailView(
      loadingState: .constant(.loaded([missingArtwork])),
      artworkLoadingStates: .constant([missingArtwork: .loaded([])]),
      selectedArtwork: .constant([missingArtwork]),
      selectedArtworkImages: .constant([:]))
  }
}
