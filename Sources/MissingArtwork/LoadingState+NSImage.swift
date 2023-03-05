//
//  LoadingState+NSImage.swift
//
//
//  Created by Greg Bolsinga on 1/20/23.
//

import AppKit
import Foundation
import LoadingState

private enum NSImageError: Error {
  case noImage
}

extension NSImageError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noImage:
      return String(
        localized: "No Image Created.",
        bundle: .module,
        comment: "Error message when an Image cannot be created from the URL.")
    }
  }
}

extension LoadingState where Value == NSImage {
  mutating func load(url: URL) async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let nsImage = NSImage.init(data: data)

      if let nsImage {
        self = .loaded(nsImage)
      } else {
        throw NSImageError.noImage
      }
    } catch {
      self = .error(error)
    }
  }
}

extension LoadingState: Equatable where Value == NSImage {
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
