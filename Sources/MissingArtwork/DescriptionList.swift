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

struct DescriptionList<Content: View>: View {
  typealias ImageContextMenuBuilder = ([(MissingArtwork, NSImage?)]) -> Content

  @ViewBuilder let imageContextMenuBuilder: ImageContextMenuBuilder

  @State private var filter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var selectedArtwork: MissingArtwork?
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var searchString: String = ""

  @State private var selectedArtworkImages: [MissingArtwork: NSImage] = [:]
  @State private var artworkLoadingStates:
    [MissingArtwork: LoadingState<[(Artwork, LoadingState<NSImage>)]>] = [:]

  @Binding var loadingState: LoadingState<[MissingArtwork]>

  @Binding var processingStates: [MissingArtwork: Description.ProcessingState]

  var missingArtworksIsEmpty: Bool {
    if let missingArtworks = loadingState.value {
      return missingArtworks.isEmpty
    }
    return true
  }

  var missingArtworksCount: Int {
    if let missingArtworks = loadingState.value {
      return missingArtworks.count
    }
    return 0
  }

  var displayableArtworks: [MissingArtwork] {
    guard let missingArtworks = loadingState.value else {
      return []
    }
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

  @ViewBuilder private var listStateOverlay: some View {
    if loadingState.isIdleOrLoading {
      ProgressView()
    } else if missingArtworksIsEmpty {
      Text(
        "No Missing Artwork", bundle: .module,
        comment: "Shown when there is no missing artwork in iTunes")
    }
  }

  @ViewBuilder private var sidebarView: some View {
    VStack {
      List(displayableArtworks, selection: $selectedArtwork) { missingArtwork in
        NavigationLink(value: missingArtwork) {
          Description(
            missingArtwork: missingArtwork,
            processingState: $processingStates[missingArtwork].defaultValue(.none))
        }
        .contextMenu {
          self.imageContextMenuBuilder([
            (missingArtwork, selectedArtworkImages[missingArtwork])
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
      Text(
        "\(displayableArtworks.count) / \(missingArtworksCount) Missing", bundle: .module,
        comment:
          "Shown at the bottom of the Missing Artwork list to indicate how many filtered items out of the total items are shown."
      )
      .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
    }
  }

  var body: some View {
    NavigationSplitView {
      sidebarView
        .navigationTitle(title)
        .frame(minWidth: 325)
        .toolbar {
          ToolbarItem {
            Menu {
              Picker(selection: $filter) {
                ForEach(FilterCategory.allCases) { category in
                  Text(category.rawValue).tag(category)
                }
              } label: {
                Text(
                  "Category", bundle: .module,
                  comment:
                    "Shown to allow user to filter by category of MissingArtwork (album or compilation)."
                )

              }
              Picker(selection: $availabilityFilter) {
                ForEach(AvailabilityCategory.allCases) { category in
                  Text(category.rawValue).tag(category)
                }
              } label: {
                Text(
                  "Artwork Availability", bundle: .module,
                  comment: "Shown to allow user to filter by artwork availability.")
              }
              Picker(selection: $sortOrder) {
                ForEach(SortOrder.allCases) { sortOrder in
                  Text(sortOrder.rawValue).tag(sortOrder)
                }
              } label: {
                Text(
                  "Sort Order", bundle: .module,
                  comment: "Shown to change the sort order of the Missing Artwork.")
              }
            } label: {
              Label {
                Text(
                  "Filters", bundle: .module,
                  comment:
                    "Title of the ToolbarItem that shows a popup of filters to apply to the displayed Missing Artwork."
                )
              } icon: {
                Image(systemName: "slider.horizontal.3")
              }
            }
          }
          ToolbarItem {
            Menu {
              self.imageContextMenuBuilder(displayableArtworks.map { ($0, nil) })
            } label: {
              Label {
                Text(
                  "Multiple", bundle: .module,
                  comment:
                    "Title of the ToolbarItem that shows a popup of actions to apply to multiple items."
                )
              } icon: {
                Image(systemName: "wand.and.rays")
              }
            }
          }
        }
    } detail: {
      DetailView(
        loadingState: $loadingState,
        artworkLoadingStates: $artworkLoadingStates,
        selectedArtwork: .constant((selectedArtwork != nil) ? [selectedArtwork!] : []),
        selectedArtworkImages: $selectedArtworkImages)
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
    let missingArtworks = [
      MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
      MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .some),
    ]
    let fakeButton1Title = "1"
    let fakeButton2Title = "2"
    DescriptionList(
      imageContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      loadingState: .constant(.loaded(missingArtworks)),
      processingStates: .constant(
        missingArtworks.reduce(into: [MissingArtwork: Description.ProcessingState]()) {
          $0[$1] = .processing
        }
      )
    )

    DescriptionList(
      imageContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      loadingState: .constant(.loaded([])),
      processingStates: .constant([:])
    )

    DescriptionList(
      imageContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      loadingState: .constant(.loading),
      processingStates: .constant([:])
    )

    DescriptionList(
      imageContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      loadingState: .constant(.idle),
      processingStates: .constant([:])
    )
  }
}
