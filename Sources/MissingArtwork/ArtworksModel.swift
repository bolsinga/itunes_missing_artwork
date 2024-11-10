//
//  ArtworksModel.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 11/4/24.
//

import MusicKit
import SwiftUI
import os

extension Logger {
  fileprivate static let artworksModel = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "artworksModel")
}

@Observable final class MissingArtworksModel<C: ArtworkProtocol> {
  var catalogArtworks: [MissingArtwork: [C]]
  var artworkImages: [C: PlatformImage]
  var artworkErrors: Set<C>
  var partialLibraryImages: [MissingArtwork: PlatformImage]

  @ObservationIgnored
  private let catalogLoader: (MissingArtwork) async throws -> [C]?
  @ObservationIgnored
  private let artworkLoader: @MainActor (C) async throws -> PlatformImage?

  init(
    catalogArtworks: [MissingArtwork: [C]],
    artworkImages: [C: PlatformImage],
    artworkErrors: Set<C>,
    partialLibraryImages: [MissingArtwork: PlatformImage],
    catalogLoader: @escaping (MissingArtwork) async throws -> [C]?,
    artworkLoader: @escaping @MainActor (C) async throws -> PlatformImage?
  ) {
    self.catalogArtworks = catalogArtworks
    self.artworkImages = artworkImages
    self.artworkErrors = artworkErrors
    self.partialLibraryImages = partialLibraryImages
    self.catalogLoader = catalogLoader
    self.artworkLoader = artworkLoader
  }

  var missingArtworksWithPlatformImages: Set<MissingArtwork> {
    Set(
      catalogArtworks.filter { $0.value.count(where: { artworkImages[$0] != nil }) > 0 }.map(\.key)
    ).union(partialLibraryImages.keys)
  }

  var missingArtworksWithErrors: Set<MissingArtwork> {
    Set(
      catalogArtworks.filter { $0.value.count(where: { artworkErrors.contains($0) }) > 0 }.map(
        \.key))
  }

  @MainActor
  func load(artwork missingArtwork: MissingArtwork) async throws {
    guard catalogArtworks[missingArtwork] == nil else {
      Logger.artworksModel.log(
        "Already loaded catalog artworks: \(missingArtwork, privacy: .public)")
      return
    }

    Logger.artworksModel.log("Loading catalog artworks: \(missingArtwork, privacy: .public)")
    do {
      catalogArtworks[missingArtwork] = try await catalogLoader(missingArtwork)
      Logger.artworksModel.log("Loaded catalog artworks: \(missingArtwork, privacy: .public)")
    } catch {
      Logger.artworksModel.log(
        "Error loading catalog artworks: \(missingArtwork, privacy: .public) \(error, privacy: .public)"
      )
      throw error
    }
  }

  @MainActor
  func reload(artwork missingArtwork: MissingArtwork) async throws {
    catalogArtworks[missingArtwork] = nil
    try await load(artwork: missingArtwork)
  }

  @MainActor
  func load(image artwork: C) async throws {
    guard artworkImages[artwork] == nil else {
      Logger.artworksModel.log("Already loaded artwork image: \(artwork, privacy: .public)")
      return
    }

    Logger.artworksModel.log("Loading artwork image: \(artwork, privacy: .public)")
    do {
      artworkImages[artwork] = try await artworkLoader(artwork)
      Logger.artworksModel.log("Loaded artwork image: \(artwork, privacy: .public)")
    } catch {
      Logger.artworksModel.log(
        "Error loading artwork image: \(artwork, privacy: .public) \(error, privacy: .public)")
      artworkErrors.insert(artwork)
      throw error
    }
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

typealias ArtworksModel = MissingArtworksModel<Artwork>

extension ArtworksModel {
  convenience init() {
    self.init(
      catalogArtworks: [:], artworkImages: [:], artworkErrors: [], partialLibraryImages: [:]
    ) {
      try await $0.fetchCatalogArtworks()
    } artworkLoader: {
      try await PlatformImage.load(artwork: $0)
    }
  }
}
