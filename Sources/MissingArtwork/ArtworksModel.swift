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
  var partialLibraryImages: [MissingArtwork: PlatformImage]

  init(partialLibraryImages: [MissingArtwork: PlatformImage]) {
    self.partialLibraryImages = partialLibraryImages
  }

  @MainActor
  func load(image missingArtwork: MissingArtwork) async throws {
    guard partialLibraryImages[missingArtwork] == nil else {
      Logger.artworksModel.log(
        "Already loaded partial library image: \(missingArtwork, privacy: .public)")
      return
    }

    Logger.artworksModel.log("Loading partial library image: \(missingArtwork, privacy: .public)")
    do {
      partialLibraryImages[missingArtwork] =
        try await missingArtwork.matchingPartialArtworkImage()
      Logger.artworksModel.log("Loaded partial library image: \(missingArtwork, privacy: .public)")
    } catch {
      Logger.artworksModel.log(
        "Error loading partial library image: \(missingArtwork, privacy: .public) \(error, privacy: .public)"
      )
      throw error
    }
  }
}

extension ArtworksModel {
  convenience init() {
    self.init(partialLibraryImages: [:])
  }
}
