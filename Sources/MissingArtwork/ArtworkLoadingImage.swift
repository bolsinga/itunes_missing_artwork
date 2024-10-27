//
//  ArtworkLoadingImage.swift
//
//
//  Created by Greg Bolsinga on 3/3/23.
//

import Foundation
import MusicKit

struct ArtworkLoadingImage: Equatable, Hashable, Sendable {
  let artwork: Artwork
  var loadingState: ArtworkPlatformImageModel
}
