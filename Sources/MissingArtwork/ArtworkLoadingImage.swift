//
//  ArtworkLoadingImage.swift
//
//
//  Created by Greg Bolsinga on 3/3/23.
//

import AppKit
import Foundation
import LoadingState
import MusicKit

struct ArtworkLoadingImage {
  let artwork: Artwork
  var loadingState: LoadingState<NSImage>
}
