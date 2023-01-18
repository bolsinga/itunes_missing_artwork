//
//  LoadingState+NSImage.swift
//
//
//  Created by Greg Bolsinga on 1/20/23.
//

import AppKit
import Foundation

private enum NSImageError: Error {
  case noImage
}

extension NSImageError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noImage:
      return "No Image Created."
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
