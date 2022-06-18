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

protocol ArtworksFetcher {
  func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws -> [URL]
}

struct DescriptionList: View {
  let fetcher: ArtworksFetcher

  @State private var filter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var imageResult = ImageResult.all
  @State private var selectedArtwork: MissingArtwork?

  @State private var searchString: String = ""

  @State var showMissingImageListOverlayProgress: Bool = false
  @State private var missingImageListOverlayMessage: String?

  @Binding var missingArtworks: [MissingArtwork]
  @Binding var artworks: [MissingArtwork: [URL]]
  @Binding var showProgressOverlay: Bool

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
        return artworks[missingArtwork]?.count == 0
      case .found:
        return artworks[missingArtwork]?.count ?? 0 > 0
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

  @ViewBuilder private var imageListOverlay: some View {
    if showMissingImageListOverlayProgress {
      ProgressView()
    } else if let message = missingImageListOverlayMessage {
      Text(message).textSelection(.enabled)
    }
  }

  @ViewBuilder private var progressOverlay: some View {
    if showProgressOverlay {
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
                missingArtwork: missingArtwork, urls: $artworks[missingArtwork]
              ).overlay(imageListOverlay)
                .task {
                  missingImageListOverlayMessage = nil

                  guard artworks[missingArtwork] == nil else {
                    return
                  }

                  showMissingImageListOverlayProgress = true
                  defer {
                    showMissingImageListOverlayProgress = false
                  }

                  do {
                    artworks[missingArtwork] = try await fetcher.fetchArtworks(
                      missingArtwork: missingArtwork, term: missingArtwork.simpleRepresentation)
                    if let urls = artworks[missingArtwork], urls.count == 0 {
                      missingImageListOverlayMessage =
                        "No image for \(missingArtwork.description)"
                    }
                  } catch {
                    missingImageListOverlayMessage =
                      "Error retrieving \(missingArtwork.description). Error: \(String(describing: error.localizedDescription))"
                  }
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
  struct Fetcher: ArtworksFetcher {
    func fetchArtworks(missingArtwork: MissingArtwork, term: String) async -> [URL] {
      return []
    }
  }

  static var previews: some View {
    DescriptionList(
      fetcher: Fetcher(),
      missingArtworks: .constant(MissingArtwork.previewArtworks),
      artworks: .constant(MissingArtwork.previewArtworkHashURLs),
      showProgressOverlay: .constant(false)
    )

    DescriptionList(
      fetcher: Fetcher(),
      missingArtworks: .constant([]),
      artworks: .constant([:]),
      showProgressOverlay: .constant(true)
    )
  }
}
