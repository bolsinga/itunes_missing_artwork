//
//  ArtworksModel.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 11/4/24.
//

import SwiftUI
import os

extension Logger {
  fileprivate static let artworksModel = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "artworksModel")
}

@Observable final class ArtworksModel {
  enum ImageState {
    case loading
    case error(Error)
    case image(PlatformImage)
  }

  var partialLibraryImages: [MissingArtwork: ImageState] = [:]

  @MainActor
  func load(image missingArtwork: MissingArtwork) async {
    guard partialLibraryImages[missingArtwork] == nil else {
      Logger.artworksModel.log(
        "Already loaded partial library image: \(missingArtwork, privacy: .public)")
      return
    }

    Logger.artworksModel.log("Loading partial library image: \(missingArtwork, privacy: .public)")
    partialLibraryImages[missingArtwork] = .loading
    do {
      partialLibraryImages[missingArtwork] = .image(
        try await missingArtwork.matchingPartialArtworkImage())
      Logger.artworksModel.log("Loaded partial library image: \(missingArtwork, privacy: .public)")
    } catch {
      Logger.artworksModel.log(
        "Error loading partial library image: \(missingArtwork, privacy: .public) \(error, privacy: .public)"
      )
      partialLibraryImages[missingArtwork] = .error(error)
    }
  }
}
