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
  @Published public var missingArtworkURLs: [MissingArtwork: [URL]]

  /// Used for previews.
  init(missingArtworks: [MissingArtwork], urls: [[URL]]) {
    self.missingArtworks = missingArtworks
    self.missingArtworkURLs = [:]
    for (missingArtwork, urls) in zip(missingArtworks, urls) {
      self.missingArtworkURLs[missingArtwork] = urls
    }
  }

  public convenience init() {
    self.init(missingArtworks: [], urls: [[]])
  }

  public func fetchMissingArtworks(token: String) async throws {
    if self.missingArtworks.isEmpty {
      async let missingArtworks = try MissingArtwork.gatherMissingArtwork()

      self.missingArtworks = try await Array(Set<MissingArtwork>(missingArtworks))

      Task.detached {
        for missingArtwork in await self.missingArtworks {
          await self.fetchImageURLs(
            missingArtwork: missingArtwork, term: missingArtwork.simpleRepresentation, token: token)
        }
      }
    }
  }

  func fetchImageURLs(missingArtwork: MissingArtwork, term: String, token: String) async {
    if self.missingArtworkURLs[missingArtwork] == nil {
      let fetcher = ArtworkURLFetcher(token: token)
      do {
        self.missingArtworkURLs[missingArtwork] = try await fetcher.fetch(searchTerm: term)
      } catch {
        debugPrint("Unable to fetch missing artwork URLs: (\(missingArtwork)) - \(error)")
        self.missingArtworkURLs[missingArtwork] = []
      }
    }
  }
}
