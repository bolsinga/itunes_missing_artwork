//
//  Model.swift
//  MissingArt
//
//  Created by Greg Bolsinga on 5/3/22.
//

import Foundation

@MainActor
public class Model: ObservableObject {
  @Published public var missingArtworks: [MissingArtwork]

  public struct IdentifiableURL: Identifiable {
    public let url: URL
    public var id: URL { return url }
  }
  @Published public var missingArtworkURLs: [MissingArtwork: [URL]]

  /// Used for previews.
  public init(missingArtworks: [MissingArtwork]) {
    self.missingArtworks = missingArtworks
    self.missingArtworkURLs = [:]
  }

  public convenience init() {
    self.init(missingArtworks: [])
  }

  public func fetchMissingArtworks() async {
    do {
      async let missingArtworks = try MissingArtwork.gatherMissingArtwork()

      self.missingArtworks = try await Array(Set<MissingArtwork>(missingArtworks))
    } catch {
      debugPrint("Unable to fetch missing artworks: \(error)")
      self.missingArtworks = []
    }
  }

  private func getImageURLs(missingArtwork: MissingArtwork, token: String) async -> [URL] {
    let fetcher = ArtworkURLFetcher(token: token)
    do {
      return try await fetcher.fetch(missingArtwork.searchURL)
    } catch {
      debugPrint("Unable to fetch missing artwork URLs: (\(missingArtwork)) - \(error)")
      return []
    }
  }

  public func fetchImageURLs(missingArtwork: MissingArtwork, token: String) async {
    let urls = await getImageURLs(missingArtwork: missingArtwork, token: token)
    self.missingArtworkURLs[missingArtwork] = urls
  }
}
