//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import SwiftUI

public struct DescriptionList: View {
  @State private var filter = FilterCategory.all

  public init(missingArtworks: [MissingArtwork]) {
    self.missingArtworks = missingArtworks
  }

  let missingArtworks: [MissingArtwork]

  var filteredArtworks: [MissingArtwork] {
    missingArtworks.filter { missingArtwork in
      (filter == .all
        || {
          switch missingArtwork {
          case .ArtistAlbum(_, _):
            return filter == .albums
          case .CompilationAlbum(_):
            return filter == .compilations
          }
        }())
    }
  }

  enum FilterCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case albums = "Albums"
    case compilations = "Compliations"

    var id: FilterCategory { self }
  }

  public var body: some View {
    VStack {
      List {
        ForEach(filteredArtworks) { missingArtwork in
          Description(missingArtwork: missingArtwork)
        }
      }
      Text("\(missingArtworks.count) Missing")
        .padding()
    }
    .toolbar {
      ToolbarItem {
        Menu {
          Picker("Category", selection: $filter) {
            ForEach(FilterCategory.allCases) { category in
              Text(category.rawValue).tag(category)
            }
          }
        } label: {
          Label("Filters", systemImage: "slider.horizontal.3")
        }
      }
    }
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
