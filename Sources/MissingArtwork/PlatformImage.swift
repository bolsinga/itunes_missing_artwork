//
//  PlatformImage.swift
//
//
//  Created by Greg Bolsinga on 3/12/23.
//

import Foundation
import MusicKit
import SwiftUI
import os

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

extension Logger {
  fileprivate static let platformImage = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "platformImage")
}

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

private enum ArtworkImageError: Error {
  case noURL(Artwork)
}

extension ArtworkImageError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noURL(let artwork):
      return String(
        localized: "No Image URL Available: \(artwork.description).",
        bundle: .module,
        comment: "Error message when MusicKit Artwork does not have an URL.")
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

extension PlatformImage {
  static func load(artwork: Artwork) async throws -> PlatformImage {
    Logger.platformImage.log("Loading artwork: \(artwork, privacy: .public)")
    guard let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight)
    else { throw ArtworkImageError.noURL(artwork) }
    return try await PlatformImage.load(url: url)
  }
}

extension PlatformImage {
  static func load(url: URL) async throws -> PlatformImage {
    Logger.platformImage.log("Load url: \(url.absoluteString, privacy: .public)")
    let (data, _) = try await URLSession.shared.data(from: url)
    return try PlatformImage(data: data)
  }
}
