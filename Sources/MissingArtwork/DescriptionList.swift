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

extension Binding {
  public func defaultValue<T>(_ value: T) -> Binding<T> where Value == T? {
    Binding<T> {
      wrappedValue ?? value
    } set: {
      wrappedValue = $0
    }
  }
}

struct DescriptionList<Content: View>: View {
  typealias MissingImage = (MissingArtwork, NSImage?)
  typealias ImageContextMenuBuilder = ([MissingImage]) -> Content

  @ViewBuilder let imageContextMenuBuilder: ImageContextMenuBuilder

  @State private var filter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var imageResult = ImageResult.all
  @State private var selectedArtwork: MissingArtwork?
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var searchString: String = ""

  @State private var selectedArtworkImages: [MissingArtwork: ArtworkImage] = [:]
  @State var artworkImages: [MissingArtwork: [ArtworkImage]] = [:]

  @Binding var missingArtworks: [MissingArtwork]

  @Binding var showProgressOverlay: Bool

  @Binding var processingStates: [MissingArtwork: Description.ProcessingState]

  var displayableArtworks: [MissingArtwork] {
    return missingArtworks.filter { missingArtwork in
      (filter == .all
        || {
          switch missingArtwork {
          case .ArtistAlbum(_, _, _):
            return filter == .albums
          case .CompilationAlbum(_, _):
            return filter == .compilations
          }
        }())
    }.filter { missingArtwork in
      (availabilityFilter == .all
        || {
          switch missingArtwork.availability {
          case .some:
            return availabilityFilter == .partial
          case .none:
            return availabilityFilter == .none
          case .unknown:
            return availabilityFilter == .unknown
          }
        }())
    }.filter { missingArtwork in
      switch imageResult {
      case .all:
        return true
      case .notFound:
        return artworkImages[missingArtwork]?.count == 0
      case .found:
        return artworkImages[missingArtwork]?.count ?? 0 > 0
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

  @ViewBuilder private var listStateOverlay: some View {
    if showProgressOverlay {
      ProgressView()
    } else if missingArtworks.isEmpty {
      Text("No Missing Artwork")
    }
  }

  @ViewBuilder private var sidebarView: some View {
    VStack {
      List(displayableArtworks, selection: $selectedArtwork) { missingArtwork in
        NavigationLink {
          MissingImageList(
            missingArtwork: missingArtwork,
            artworkImages: $artworkImages[missingArtwork].defaultValue([]),
            selectedArtworkImage: $selectedArtworkImages[missingArtwork],
            selectedArtwork: $selectedArtwork
          )
        } label: {
          Description(
            missingArtwork: missingArtwork,
            processingState: $processingStates[missingArtwork].defaultValue(.none))
        }
        .contextMenu {
          self.imageContextMenuBuilder([
            (missingArtwork, selectedArtworkImages[missingArtwork]?.loadingState.value)
          ])
        }
        .tag(missingArtwork)
      }
      .overlay(listStateOverlay)
      .searchable(text: $searchString) {
        ForEach(searchSuggestions) { suggestion in
          Text(suggestion.description).searchCompletion(suggestion.description)
        }
      }
      Divider()
      Text("\(displayableArtworks.count) / \(missingArtworks.count) Missing")
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
    }
  }

  var body: some View {
    NavigationView {
      sidebarView
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
          ToolbarItem {
            Menu {
              self.imageContextMenuBuilder(displayableArtworks.map { ($0, nil) })
            } label: {
              Label("Multiple", systemImage: "wand.and.rays")
            }
          }
        }

      if displayableArtworks.count > 0 {
        Text("Select an Item")
      }
    }
  }

  fileprivate var searchSuggestions: [MissingArtwork] {
    displayableArtworks.filter {
      $0.description.localizedCaseInsensitiveContains(searchString)
        && $0.description.localizedCaseInsensitiveCompare(searchString) != .orderedSame
    }
  }
}

struct DescriptionList_Previews: PreviewProvider {
  static var previews: some View {
    DescriptionList(
      imageContextMenuBuilder: { items in
        Button("1") {}
        Button("2") {}
      },
      missingArtworks: .constant([
        MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
        MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .some),
      ]),
      showProgressOverlay: .constant(false),
      processingStates: .constant([
        MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none): .processing,
        MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .none): .success,
      ])
    )

    DescriptionList(
      imageContextMenuBuilder: { items in
        Button("1") {}
        Button("2") {}
      },
      missingArtworks: .constant([]),
      showProgressOverlay: .constant(true),
      processingStates: .constant([:])
    )
  }
}
