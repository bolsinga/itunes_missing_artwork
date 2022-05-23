//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import SwiftUI

public struct DescriptionList: View {
  let token: String

  @State private var filter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var selectedArtwork: MissingArtwork?

  @EnvironmentObject var model: Model

  public init(token: String) {
    self.token = token
  }

  var missingArtworks: [MissingArtwork] {
    model.missingArtworks
  }

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

  @ViewBuilder private var progressOverlay: some View {
    if filteredArtworks.count == 0 {
      ProgressView()
    }
  }

  public var body: some View {
    NavigationView {
      VStack {
        List(selection: $selectedArtwork) {
          ForEach(filteredArtworks) { missingArtwork in
            NavigationLink {
              MissingImageList(missingArtwork: missingArtwork, token: token)
            } label: {
              Description(missingArtwork: missingArtwork)
            }
            .tag(missingArtwork)
          }
        }
        .overlay(progressOverlay)
        Divider()
        Text("\(missingArtworks.count) Missing")
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
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

      if filteredArtworks.count > 0 {
        Text("Select an Item")
      }
    }
    .task {
      await model.fetchMissingArtworks(token: token)
    }
  }
}

struct DescriptionList_Previews: PreviewProvider {
  static var previews: some View {
    DescriptionList(token: "")
      .environmentObject(Model.preview)
  }
}
