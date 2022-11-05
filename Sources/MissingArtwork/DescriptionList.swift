//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import MusicKit
import SwiftUI

extension MissingArtwork {
  func matches(_ string: String) -> Bool {
    string.isEmpty || description.localizedCaseInsensitiveContains(string)
  }
}

protocol ArtworksFetcher {
  func fetchArtworks(missingArtwork: MissingArtwork, term: String) async throws -> [Artwork]
}

struct DescriptionList<Content: View>: View {
  let fetcher: ArtworksFetcher
  @ViewBuilder let partialImageContextMenuBuilder: (_ missingArtwork: MissingArtwork) -> Content

  @State private var filter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var imageResult = ImageResult.all
  @State private var selectedArtwork: MissingArtwork?
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var searchString: String = ""

  @State var showMissingImageListOverlayProgress: Bool = false
  @State private var missingImageListOverlayMessage: String?

  @Binding var missingArtworks: [(MissingArtwork, ArtworkAvailability)]
  @Binding var artworks: [MissingArtwork: [Artwork]]
  @Binding var showProgressOverlay: Bool

  var displayableArtworks: [(MissingArtwork, ArtworkAvailability)] {
    return missingArtworks.filter { (missingArtwork, _) in
      (filter == .all
        || {
          switch missingArtwork {
          case .ArtistAlbum(_, _):
            return filter == .albums
          case .CompilationAlbum(_):
            return filter == .compilations
          }
        }())
    }.filter { (_, availability) in
      (availabilityFilter == .all
        || {
          switch availability {
          case .some:
            return availabilityFilter == .partial
          case .none:
            return availabilityFilter == .none
          case .unknown:
            return availabilityFilter == .unknown
          }
        }())
    }.filter { (missingArtwork, _) in
      switch imageResult {
      case .all:
        return true
      case .notFound:
        return artworks[missingArtwork]?.count == 0
      case .found:
        return artworks[missingArtwork]?.count ?? 0 > 0
      }
    }.filter { (missingArtwork, _) in
      missingArtwork.matches(searchString)
    }
    .sorted {
      switch sortOrder {
      case .ascending:
        return $0.0 < $1.0
      case .descending:
        return $1.0 < $0.0
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

  enum AvailabilityCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case none = "No Artwork"
    case partial = "Partial Artwork"
    case unknown = "Unknown"

    var id: AvailabilityCategory { self }
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
          ForEach(displayableArtworks, id: \.0) { (missingArtwork, availability) in
            NavigationLink {
              MissingImageList(artworks: $artworks[missingArtwork])
                .overlay(imageListOverlay)
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
                      missingArtwork: missingArtwork, term: missingArtwork.simpleRepresentation
                    )

                    if let items = artworks[missingArtwork], items.isEmpty {
                      missingImageListOverlayMessage =
                        "No image for \(missingArtwork.description)"
                    }
                  } catch {
                    missingImageListOverlayMessage =
                      "Error retrieving \(missingArtwork.description). Error: \(String(describing: error.localizedDescription))"
                  }
                }
            } label: {
              Description(missingArtwork: missingArtwork, availability: availability)
            }
            .contextMenu {
              self.partialImageContextMenuBuilder(missingArtwork)
                .disabled(availability != .some)
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
            Picker("Artwork Availability", selection: $availabilityFilter) {
              ForEach(AvailabilityCategory.allCases) { category in
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
    displayableArtworks.map { $0.0 }.filter {
      $0.description.localizedCaseInsensitiveContains(searchString)
        && $0.description.localizedCaseInsensitiveCompare(searchString) != .orderedSame
    }
  }
}

struct DescriptionList_Previews: PreviewProvider {
  struct Fetcher: ArtworksFetcher {
    func fetchArtworks(missingArtwork: MissingArtwork, term: String) async -> [Artwork] {
      return []
    }
  }

  static var previews: some View {
    DescriptionList(
      fetcher: Fetcher(),
      partialImageContextMenuBuilder: { missingArtwork in
        Button("") {}
      },
      missingArtworks: .constant([
        (MissingArtwork.ArtistAlbum("The Stooges", "Fun House"), .none),
        (MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1"), .some),
      ]),
      artworks: .constant([:]),
      showProgressOverlay: .constant(false)
    )

    DescriptionList(
      fetcher: Fetcher(),
      partialImageContextMenuBuilder: { missingArtwork in
        Button("") {
        }
      },
      missingArtworks: .constant([]),
      artworks: .constant([:]),
      showProgressOverlay: .constant(true)
    )
  }
}
