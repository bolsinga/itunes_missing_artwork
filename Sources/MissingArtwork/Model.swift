//
//  Model.swift
//  MissingArt
//
//  Created by Greg Bolsinga on 5/3/22.
//

import Foundation

public class Model: ObservableObject {
  public var missingArtworks: [MissingArtwork]

  public init() {
    do {
      missingArtworks = Array(Set<MissingArtwork>(try MissingArtwork.gatherMissingArtwork()))
    } catch {
      missingArtworks = []
    }
  }

  public init(missingArtworks: [MissingArtwork]) {
    self.missingArtworks = missingArtworks
  }
}
