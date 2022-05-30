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

  struct IdentifiableURL: Identifiable {
    let url: URL
    var id: URL { return url }
  }
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

  public func fetchMissingArtworks(token: String) async {
    if self.missingArtworks.isEmpty {
      do {
        async let missingArtworks = try MissingArtwork.gatherMissingArtwork()

        self.missingArtworks = try await Array(Set<MissingArtwork>(missingArtworks))

        for missingArtwork in self.missingArtworks {
          await fetchImageURLs(missingArtwork: missingArtwork, token: token)
        }
      } catch {
        debugPrint("Unable to fetch missing artworks: \(error)")
        self.missingArtworks = []
      }
    }
  }

  func fetchImageURLs(missingArtwork: MissingArtwork, token: String) async {
    if self.missingArtworkURLs[missingArtwork] == nil {
      let fetcher = ArtworkURLFetcher(token: token)
      do {
        self.missingArtworkURLs[missingArtwork] = try await fetcher.fetch(missingArtwork.searchURL)
      } catch {
        debugPrint("Unable to fetch missing artwork URLs: (\(missingArtwork)) - \(error)")
        self.missingArtworkURLs[missingArtwork] = []
      }
    }
  }
}
