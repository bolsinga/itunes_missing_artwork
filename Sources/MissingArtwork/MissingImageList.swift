//
//  MissingImageList.swift
//
//
//  Created by Greg Bolsinga on 5/14/22.
//

import MusicKit
import SwiftUI

struct MissingImageList<C: ArtworkProtocol>: View {
  let missingArtwork: MissingArtwork
  var model: MissingArtworksModel<C>
  @State private var error: Error?

  @Binding var selectedArtwork: C?

  var body: some View {
    VStack {
      if let catalogArtworks = model.catalogArtworks[missingArtwork] {
        if catalogArtworks.isEmpty {
          Text(
            "No Images Available", bundle: .module,
            comment: "Shown when no images are loaded for repair.")
        } else {
          if missingArtwork.availability == .none {
            Text(
              "Select an Image to Use for Repair", bundle: .module,
              comment:
                "Shown when Missing Image List has images for a missing artwork with no artwork."
            )
            .font(.headline)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
          }
          GeometryReader { proxy in
            List(catalogArtworks, id: \.self, selection: $selectedArtwork) { artwork in
              MissingArtworkImage(width: proxy.size.width, artwork: artwork, model: model)
                .tag(artwork)
            }
          }
        }
      } else if let error {
        VStack(alignment: .center) {
          Text(error.localizedDescription)
          if error as? NoArtworkError == nil {
            Button {
              Task {
                self.error = nil
                do {
                  try await model.reload(artwork: missingArtwork)
                } catch {
                  self.error = error
                }
              }
            } label: {
              Text(
                "Retry Loading Image", bundle: .module,
                comment: "Button title to retry loading an image.")
            }
          }
        }
      } else {
        ProgressView()
      }
    }
    .task(id: missingArtwork) {
      do {
        try await model.load(artwork: missingArtwork)
      } catch {
        self.error = error
      }
    }
  }
}

#Preview("Loading") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  MissingImageList(
    missingArtwork: missingArtwork,
    model: MissingArtworksModel<PreviewArtwork>(),
    selectedArtwork: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Loaded Empty") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  MissingImageList(
    missingArtwork: missingArtwork,
    model: MissingArtworksModel<PreviewArtwork>(catalogLoaderResult: .result([])),
    selectedArtwork: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Loaded Values - Availability None") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  MissingImageList(
    missingArtwork: missingArtwork,
    model: MissingArtworksModel(catalogArtworks: [missingArtwork: [PreviewArtwork()]]),
    selectedArtwork: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Loaded Values - Availability Some") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .some)
  MissingImageList(
    missingArtwork: missingArtwork,
    model: MissingArtworksModel(catalogArtworks: [missingArtwork: [PreviewArtwork()]]),
    selectedArtwork: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Error - NoArtworkError") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  MissingImageList(
    missingArtwork: missingArtwork,
    model: MissingArtworksModel<PreviewArtwork>(
      catalogLoaderResult: .error(NoArtworkError.noneFound(missingArtwork.simpleRepresentation))),
    selectedArtwork: .constant(nil)
  )
  .frame(width: 300, height: 300)
}

#Preview("Error") {
  let missingArtwork = MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none)
  MissingImageList(
    missingArtwork: missingArtwork,
    model: MissingArtworksModel<PreviewArtwork>(catalogLoaderResult: .error(CancellationError())),
    selectedArtwork: .constant(nil)
  )
  .frame(width: 300, height: 300)
}
