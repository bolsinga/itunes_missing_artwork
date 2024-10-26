//
//  LoadingModel+PlatformImage.swift
//
//
//  Created by Greg Bolsinga on 1/20/23.
//

import Foundation
import MusicKit

extension LoadingModel: Equatable where T == PlatformImage {
  static func == (lhs: LoadingModel<T, C>, rhs: LoadingModel<T, C>) -> Bool {
    if let lhValue = lhs.value, let rhValue = rhs.value {
      return lhValue == rhValue
    }
    if let lhError = lhs.error, let rhError = rhs.error {
      return lhError.localizedDescription == rhError.localizedDescription  // Questionable.
    }
    return false
  }
}

extension LoadingModel: Hashable where T == PlatformImage {
  func hash(into hasher: inout Hasher) {
    if let value {
      hasher.combine(value)
    }
    if let error {
      hasher.combine(error.localizedDescription)  // Questionable.)
    }
  }
}

typealias ArtworkPlatformImageModel = LoadingModel<PlatformImage, Artwork>
extension PlatformImage {
  static func createArtworkModel() -> ArtworkPlatformImageModel {
    ArtworkPlatformImageModel { artwork in
      guard let artwork else {
        fatalError("Artwork cannot be nil")
      }
      do {
        return (try await PlatformImage.load(artwork: artwork), nil)
      } catch {
        return (nil, error)
      }
    }
  }
}
