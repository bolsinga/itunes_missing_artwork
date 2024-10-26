//
//  LoadingState+PlatformImage.swift
//
//
//  Created by Greg Bolsinga on 1/20/23.
//

import Foundation

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
