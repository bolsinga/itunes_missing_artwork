//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import SwiftUI

extension MissingArtwork {
  func matches(_ string: String) -> Bool {
    string.isEmpty || description.localizedCaseInsensitiveContains(string)
  }
}

struct DescriptionList: View {
  let token: String

  @State private var filter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var imageResult = ImageResult.all
  @State private var selectedArtwork: MissingArtwork?

  @State private var searchString: String = ""

  @EnvironmentObject var model: Model

  @Binding var missingArtworks: [MissingArtwork]
  @Binding var missingArtworkURLs: [MissingArtwork: [URL]]

  var displayableArtworks: [MissingArtwork] {
    return missingArtworks.filter { missingArtwork in
      (filter == .all
        || {
          switch missingArtwork {
          case .ArtistAlbum(_, _):
            return filter == .albums
          case .CompilationAlbum(_):
            return filter == .compilations
          }
        }())
    }.filter { missingArtwork in
      switch imageResult {
      case .all:
        return true
      case .notFound:
        return missingArtworkURLs[missingArtwork]?.count == 0
      case .found:
        return missingArtworkURLs[missingArtwork]?.count ?? 0 > 0
      }
    }.filter { missingArtwork in
      missingArtwork.matches(searchString)
    }
    .sorted {
      switch sortOrder {
      case .ascending:
        return $0 < $1
      case .descending:
        return $1 < $0
      }
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

  enum ImageResult: String, CaseIterable, Identifiable {
    case all = "All"
    case notFound = "Not Found"
    case found = "Found"

    var id: ImageResult { self }
  }

  @ViewBuilder private var progressOverlay: some View {
    if displayableArtworks.count == 0 {
      ProgressView()
    }
  }

  var body: some View {
    NavigationView {
      VStack {
        List(selection: $selectedArtwork) {
          ForEach(displayableArtworks) { missingArtwork in
            NavigationLink {
              MissingImageList(
                missingArtwork: missingArtwork, urls: $missingArtworkURLs[missingArtwork]
              )
              .task {
                await model.fetchImageURLs(missingArtwork: missingArtwork, token: token)
              }
            } label: {
              Description(missingArtwork: missingArtwork)
            }
            .tag(missingArtwork)
          }
        }
        .overlay(progressOverlay)
        .searchable(text: $searchString) {
          ForEach(searchSuggestions) { suggestion in
            Text(suggestion.description).searchCompletion(suggestion.description)
          }
        }
        Divider()
        Text("\(displayableArtworks.count) / \(missingArtworks.count) Missing")
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
            Picker("Image Result", selection: $imageResult) {
              ForEach(ImageResult.allCases) { imageResult in
                Text(imageResult.rawValue).tag(imageResult)
              }
            }
          } label: {
            Label("Filters", systemImage: "slider.horizontal.3")
          }
        }
      }

      if displayableArtworks.count > 0 {
        Text("Select an Item")
      }
    }
  }

  fileprivate var searchSuggestions: [MissingArtwork] {
    missingArtworks.filter {
      $0.description.localizedCaseInsensitiveContains(searchString)
        && $0.description.localizedCaseInsensitiveCompare(searchString) != .orderedSame
    }
  }
}

struct DescriptionList_Previews: PreviewProvider {
  static var previews: some View {
    DescriptionList(
      token: "", missingArtworks: .constant(Model.preview.missingArtworks),
      missingArtworkURLs: .constant(Model.preview.missingArtworkURLs)
    )
    .environmentObject(Model.preview)
  }
}
