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

  public func fetchMissingArtworks(token: String) async {
    if self.missingArtworks.isEmpty {
      do {
        async let missingArtworks = try MissingArtwork.gatherMissingArtwork()

        self.missingArtworks = try await Array(Set<MissingArtwork>(missingArtworks))
      } catch {
        debugPrint("Unable to fetch missing artworks: \(error)")
        self.missingArtworks = []
      }
    }
  }

  func searchURL(term: String, limit: Int = 2) -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.music.apple.com"
    urlComponents.path = "/v1/catalog/us/search"
    urlComponents.queryItems = [
      URLQueryItem(name: "term", value: term),
      URLQueryItem(name: "types", value: "albums"),
      URLQueryItem(name: "limit", value: "\(limit)"),
    ]
    if let url = urlComponents.url {
      return url
    }
    return URL(string: "missing")!  // Use an bogus URL and allow the networking layer return an error.
  }

  func fetchImageURLs(missingArtwork: MissingArtwork, term: String, token: String) async {
    if self.missingArtworkURLs[missingArtwork] == nil {
      let fetcher = ArtworkURLFetcher(token: token)
      do {
        self.missingArtworkURLs[missingArtwork] = try await fetcher.fetch(searchURL(term: term))
      } catch {
        debugPrint("Unable to fetch missing artwork URLs: (\(missingArtwork)) - \(error)")
        self.missingArtworkURLs[missingArtwork] = []
      }
    }
  }
}
