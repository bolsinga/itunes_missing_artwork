//
//  MissingArtworkTypeChart.swift
//
//
//  Created by Greg Bolsinga on 1/28/23.
//

import Charts
import SwiftUI

struct MissingArtworkTypeChart: View {
  let missingArtworks: [MissingArtwork]

  private func albumCountText(_ count: Int) -> Text {
    Text(
      "\(count) Album(s)",
      bundle: .module,
      comment: "Text to show how many albums there are, plural. Parameter is an Int.")
  }

  struct MissingArtworkTypeData {
    let type: String
    let quantity: Int
  }

  var missingArtworkTypeData: [MissingArtworkTypeData] {
    let partial = MissingArtworkTypeData(
      type: "Partial Artwork", quantity: missingArtworks.filter { $0.availability == .some }.count)
    let none = MissingArtworkTypeData(
      type: "No Artwork", quantity: missingArtworks.filter { $0.availability == .none }.count)
    return [partial, none]
  }

  var body: some View {
    Chart(missingArtworkTypeData, id: \.type) { data in
      BarMark(
        x: .value(
          Text(
            "Artwork Type",
            bundle: .module,
            comment: "Label in the chart for the Artwork Type of the missing artwork."), data.type),
        y: .value(
          Text(
            "Quantity", bundle: .module,
            comment: "Label in the chart for the quantity of the missing artwork."),
          data.quantity)
      )
      .annotation(position: .top) {
        albumCountText(data.quantity)
      }
      .cornerRadius(10)
    }
    .padding()
  }
}

struct MissingArtworkTypeChart_Previews: PreviewProvider {
  static var previews: some View {
    let missingArtworks = [
      MissingArtwork.ArtistAlbum("Sonic Youth", "Evol", .none),
      MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
      MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .some),
    ]
    MissingArtworkTypeChart(missingArtworks: missingArtworks)

    MissingArtworkTypeChart(missingArtworks: [missingArtworks.first!])
  }
}
