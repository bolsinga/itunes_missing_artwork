//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import SwiftUI

public struct DescriptionList: View {
  public init(missingArtworks: [MissingArtwork]) {
    self.missingArtworks = missingArtworks
  }

  let missingArtworks: [MissingArtwork]

  public var body: some View {
    List {
      ForEach(missingArtworks) { missingArtwork in
        Description(missingArtwork: missingArtwork)
      }
    }
    Text("\(missingArtworks.count) Missing")
      .padding()
  }
}

struct DescriptionList_Previews: PreviewProvider {
  static var previews: some View {
    let missingArtworks = [
      MissingArtwork.ArtistAlbum("The Stooges", "Fun House"),
      .CompilationAlbum("Beleza Tropical: Brazil Classics 1"),
    ]

    DescriptionList(missingArtworks: missingArtworks)
  }
}
