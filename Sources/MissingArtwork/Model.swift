//
//  Model.swift
//  MissingArt
//
//  Created by Greg Bolsinga on 5/3/22.
//

import Foundation
import MusicKit

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

  public func fetchMissingArtworks() async throws {
    if self.missingArtworks.isEmpty {
      async let missingArtworks = try MissingArtwork.gatherMissingArtwork()

      self.missingArtworks = try await Array(Set<MissingArtwork>(missingArtworks))
    }
  }

  func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws {
    if self.missingArtworkURLs[missingArtwork] == nil {
      var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
      searchRequest.limit = 2
      let searchResponse = try await searchRequest.response()
      self.missingArtworkURLs[missingArtwork] = searchResponse.albums.compactMap(\.artwork)
        .compactMap {
          $0.url(width: $0.maximumWidth, height: $0.maximumHeight)
        }
    }
  }
}
