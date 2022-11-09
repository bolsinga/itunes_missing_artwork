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
    ArtworkImage(artwork, width: width)
  }
}
