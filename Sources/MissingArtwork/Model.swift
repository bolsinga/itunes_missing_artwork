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

  /// Used for previews.
  public init(missingArtworks: [MissingArtwork]) {
    self.missingArtworks = missingArtworks
  }

  public convenience init() {
    self.init(missingArtworks: [])
  }

  public func fetchMissingArtworks() {
    do {
      self.missingArtworks = Array(Set<MissingArtwork>(try MissingArtwork.gatherMissingArtwork()))
    } catch {
      debugPrint("Unabled to fetch missing artworks: \(error)")
      self.missingArtworks = []
    }
  }
}
