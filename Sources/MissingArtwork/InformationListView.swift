//
//  InformationListView.swift
//
//
//  Created by Greg Bolsinga on 2/6/23.
//

import Foundation
import SwiftUI

struct InformationListView: View {
  let missingArtworks: [MissingArtwork]
  let missingArtworkWithImages: Set<MissingArtwork>
  let missingArtworksNoImageFound: Set<MissingArtwork>
  @Binding var processingStates: [MissingArtwork: ProcessingState]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        ForEach(missingArtworks) { missingArtwork in
          Information(
            missingArtwork: missingArtwork,
            imageRepair: missingArtworksNoImageFound.contains(missingArtwork)
              ? .notAvailable
              : missingArtworkWithImages.contains(missingArtwork) ? .ready : .notSelected,
            processingState: processingStates[missingArtwork] != nil
              ? processingStates[missingArtwork]! : .none)
        }
      }
    }
  }
}

#Preview {
  let missingArtworks = [
    MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none),
    MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
    MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .some),
  ]

  InformationListView(
    missingArtworks: missingArtworks,
    missingArtworkWithImages: [missingArtworks[1]],
    missingArtworksNoImageFound: [missingArtworks[2]],
    processingStates: .constant([missingArtworks[1]: .processing]))
}
