//
//  MissingArtwork+MusicAPI.swift
//
//
//  Created by Greg Bolsinga on 8/29/21.
//

import Foundation

extension MissingArtwork {
  var searchURL: URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.music.apple.com"
    urlComponents.path = "/v1/catalog/us/search"
    urlComponents.queryItems = [
      URLQueryItem(name: "term", value: self.simpleRepresentation),
      URLQueryItem(name: "types", value: "albums"),
      URLQueryItem(name: "limit", value: "2"),
    ]
    if let url = urlComponents.url {
      return url
    }
    return URL(string: "missing")!  // Use an bogus URL and allow the networking layer return an error.
  }
}