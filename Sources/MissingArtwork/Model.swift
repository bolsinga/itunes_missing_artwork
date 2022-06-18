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

  public func fetchMissingArtworks() async throws -> [MissingArtwork] {
    async let missingArtworks = try MissingArtwork.gatherMissingArtwork()
    return try await Array(Set<MissingArtwork>(missingArtworks))
  }

  func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws -> [URL] {
    var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self])
    searchRequest.limit = 2
    let searchResponse = try await searchRequest.response()
    return searchResponse.albums.compactMap(\.artwork)
      .compactMap {
        $0.url(width: $0.maximumWidth, height: $0.maximumHeight)
      }
  }
}
