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

  var body: some View {
    MissingImageList(
      missingArtwork: selectedArtwork.first,
      selectable: .constant(!loadingState.isIdleOrLoading && !missingArtworksIsEmpty),
      loadingState: (selectedArtwork.first != nil)
        ? $artworkLoadingStates[selectedArtwork.first!].defaultValue(.idle) : .constant(.idle),
      selectedArtworkImage: (selectedArtwork.first != nil)
        ? $selectedArtworkImages[selectedArtwork.first!] : .constant(nil))
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
