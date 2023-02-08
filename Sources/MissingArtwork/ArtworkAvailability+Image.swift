//
//  ArtworkAvailability+Image.swift
//
//
//  Created by Greg Bolsinga on 2/8/23.
//

import SwiftUI

extension ArtworkAvailability {
  @ViewBuilder var representingView: some View {
    if case .some = self {
      Image(systemName: "questionmark.square.dashed")
        .imageScale(.large)
        .help(
          Text(
            "Partial Artwork", bundle: .module,
            comment: "Help string shown when album artwork is partially set."))
    } else if case .unknown = self {
      Image(systemName: "questionmark.square.dashed").foregroundColor(.red)
        .imageScale(.large)
        .help(
          Text(
            "No Artwork", bundle: .module,
            comment: "Help string shown when album artwork does not exist and must be searched for."
          ))
    }
  }
}
