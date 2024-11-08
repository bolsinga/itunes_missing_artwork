//
//  ArtworkLoadingImage.swift
//
//
//  Created by Greg Bolsinga on 3/3/23.
//

import Foundation
import MusicKit

struct LoadingImage<A: MissingArtworkProtocol>: Equatable, Hashable, Sendable {
  let artwork: A
  var loadingState: LoadingModel<PlatformImage, A>
}

typealias ArtworkLoadingImage = LoadingImage<Artwork>
