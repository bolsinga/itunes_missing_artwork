//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import SwiftUI

public struct DescriptionList: View {
  @State private var filter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var selectedArtwork: MissingArtwork?

  public init(missingArtworks: [MissingArtwork]) {
    self.missingArtworks = missingArtworks
  }

  let missingArtworks: [MissingArtwork]

  var sortedArtworks: [MissingArtwork] {
    missingArtworks.sorted {
      switch sortOrder {
      case .ascending:
        return $0 < $1
      case .descending:
        return $1 < $0
      }
    }
  }

  var filteredArtworks: [MissingArtwork] {
    sortedArtworks.filter { missingArtwork in
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

  var title: String {
    filter == .all ? "Missing Artwork" : filter.rawValue
  }

  enum FilterCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case albums = "Albums"
    case compilations = "Compliations"

    var id: FilterCategory { self }
  }

  enum SortOrder: String, CaseIterable, Identifiable {
    case ascending = "Ascending"
    case descending = "Descending"

    var id: SortOrder { self }
  }

  public var body: some View {
    NavigationView {
      VStack {
        List(selection: $selectedArtwork) {
          ForEach(filteredArtworks) { missingArtwork in
            NavigationLink {
              Text(missingArtwork.simpleRepresentation)
            } label: {
              Description(missingArtwork: missingArtwork)
            }
            .tag(missingArtwork)
          }
        }
        Text("\(missingArtworks.count) Missing")
          .padding()
      }
      .navigationTitle(title)
      .frame(minWidth: 325)
      .toolbar {
        ToolbarItem {
          Menu {
            Picker("Category", selection: $filter) {
              ForEach(FilterCategory.allCases) { category in
                Text(category.rawValue).tag(category)
              }
            }
            Picker("Sort Order", selection: $sortOrder) {
              ForEach(SortOrder.allCases) { sortOrder in
                Text(sortOrder.rawValue).tag(sortOrder)
              }
            }
          } label: {
            Label("Filters", systemImage: "slider.horizontal.3")
          }
        }
      }

      Text("Select an Item")
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
