//
//  LoadingState+PlatformImage.swift
//
//
//  Created by Greg Bolsinga on 1/20/23.
//

import Foundation
import LoadingState

extension LoadingState where Value == PlatformImage {
  mutating func load(url: URL) async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      self = .loaded(try PlatformImage(data: data))
    } catch {
      self = .error(error)
    }
  }

  mutating func loadImage(missingArtwork: MissingArtwork) async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let image = try await missingArtwork.matchingPartialArtworkImage()

      self = .loaded(image)
    } catch {
      self = .error(error)
    }
  }
}

extension LoadingState: Equatable where Value == PlatformImage {
  public static func == (lhs: LoadingState<Value>, rhs: LoadingState<Value>) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
      return true
    case (.loading, .loading):
      return true
    case (.error(let error1), .error(let error2)):
      return error1.localizedDescription == error2.localizedDescription  // Questionable.
    case (.loaded(let lhValue), .loaded(let rhValue)):
      return lhValue == rhValue
    default:
      return false
    }
  }
}

extension LoadingState: Hashable where Value == PlatformImage {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .idle:
      hasher.combine("idle")
    case .loading:
      hasher.combine("loading")
    case .error(let error):
      hasher.combine(error.localizedDescription)  // Questionable.
    case .loaded(let platformImage):
      hasher.combine(platformImage)
    }
  }
}
