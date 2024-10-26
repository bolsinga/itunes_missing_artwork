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
  var loadingState: ArtworkPlatformImageModel

  var body: some View {
    Group {
      if loadingState.isIdleOrLoading {
        if let backgroundColor = artwork.backgroundColor {
          Color(cgColor: backgroundColor)
            .frame(width: width, height: CGFloat(artwork.maximumHeight))
        } else {
          ProgressView()
        }
      } else if let error = loadingState.error {
        Text(
          "Unable to load image: \(error.localizedDescription)", bundle: .module,
          comment: "Message when an image URL cannot be loaded.")
      } else if let platformImage = loadingState.value {
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      }
    }
    .frame(width: width)
    .task {
      await loadingState.load(artwork)
    }
  }
}
