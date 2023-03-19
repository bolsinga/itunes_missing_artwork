//
//  PlatformImage.swift
//
//
//  Created by Greg Bolsinga on 3/12/23.
//

import Foundation
import SwiftUI

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

private enum PlatformImageError: Error {
  case noImage
}

extension PlatformImageError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noImage:
      return String(
        localized: "No Image Created.",
        bundle: .module,
        comment: "Error message when an Image cannot be created from the data.")
    }
  }
}

public struct PlatformImage: Equatable, Hashable {
  #if canImport(AppKit)
    public let image: NSImage
  #elseif canImport(UIKit)
    public let image: UIImage
  #endif

  init(data: Data) throws {
    #if canImport(AppKit)
      guard let image = NSImage(data: data) else {
        throw PlatformImageError.noImage
      }
    #elseif canImport(UIKit)
      guard let image = UIImage(data: data) else {
        throw PlatformImageError.noImage
      }
    #endif
    self.image = image
  }

  #if canImport(AppKit)
    init(image: NSImage) {
      self.image = image
    }
  #elseif canImport(UIKit)
    init(image: UIImage) {
      self.image = image
    }
  #endif
}

extension PlatformImage {
  @ViewBuilder var representingImage: Image {
    #if canImport(AppKit)
      Image(nsImage: image)
    #elseif canImport(UIKit)
      Image(uiImage: image)
    #endif
  }
}
