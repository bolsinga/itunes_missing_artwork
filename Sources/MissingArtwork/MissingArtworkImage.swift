//
//  MissingArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/8/22.
//

import MusicKit
import SwiftUI

struct MissingArtworkImage: View {
  let artwork: Artwork

  let width: CGFloat

  var body: some View {
    if let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight) {
      AsyncImage(url: url) { phase in
        if let image = phase.image {
          image.resizable().aspectRatio(contentMode: .fit)
        } else if let error = phase.error {
          Text("Unable to load image: \(error.localizedDescription)")
        } else {
          if let backgroundColor = artwork.backgroundColor {
            Color(cgColor: backgroundColor)
              .frame(width: width, height: CGFloat(artwork.maximumHeight))
          } else {
            ProgressView()
          }
        }
      }
      .frame(width: width)
    } else {
      Text("Unable to get URL for Artwork")
    }
  }
}
