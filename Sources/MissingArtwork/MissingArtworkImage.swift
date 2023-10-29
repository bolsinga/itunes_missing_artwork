//
//  MissingArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/8/22.
//

import MusicKit
import SwiftUI

struct MissingArtworkImage: View {
  let width: CGFloat

  let artwork: Artwork
  @Binding var loadingState: LoadingState<PlatformImage>

  var body: some View {
    Group {
      switch loadingState {
      case .idle, .loading:
        if let backgroundColor = artwork.backgroundColor {
          Color(cgColor: backgroundColor)
            .frame(width: width, height: CGFloat(artwork.maximumHeight))
        } else {
          ProgressView()
        }
      case .error(let error):
        Text(
          "Unable to load image: \(error.localizedDescription)", bundle: .module,
          comment: "Message when an image URL cannot be loaded.")
      case .loaded(let platformImage):
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      }
    }
    .frame(width: width)
    .task {
      await loadingState.load(artwork: artwork)
    }
  }
}
