//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import MusicKit
import SwiftUI

struct DescriptionList<Content: View>: View {
  typealias ImageContextMenuBuilder = ([(MissingArtwork, NSImage?)]) -> Content

  @ViewBuilder let imageContextMenuBuilder: ImageContextMenuBuilder

  @State private var categoryFilter = FilterCategory.all
  @State private var sortOrder = SortOrder.ascending
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var selectedArtworks: Set<MissingArtwork> = []

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
    return missingArtworks.filterForDisplay(
      categoryFilter: categoryFilter, availabilityFilter: availabilityFilter,
      searchString: searchString, sortOrder: sortOrder)
  }

  var title: String {
    categoryFilter == .all ? "Missing Artwork" : categoryFilter.rawValue
  }

  private func clearSelectionIfNotDisplayable() {
    selectedArtworks = selectedArtworks.intersection(displayableArtworks)
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
      List(displayableArtworks, selection: $selectedArtworks) { missingArtwork in
        NavigationLink(value: missingArtwork) {
          Description(
            missingArtwork: missingArtwork,
            processingState: $processingStates[missingArtwork].defaultValue(.none))
        }
        .contextMenu {
          self.imageContextMenuBuilder(selectedArtworks.map { ($0, selectedArtworkImages[$0]) })
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
        .filtersToolbar(
          categoryFilter: $categoryFilter, availabilityFilter: $availabilityFilter,
          sortOrder: $sortOrder)
    } detail: {
      DetailView(
        loadingState: $loadingState,
        artworkLoadingStates: $artworkLoadingStates,
        selectedArtworks: $selectedArtworks,
        selectedArtworkImages: $selectedArtworkImages)
    }.onChange(of: categoryFilter) { _ in
      clearSelectionIfNotDisplayable()
    }.onChange(of: availabilityFilter) { _ in
      clearSelectionIfNotDisplayable()
    }.onChange(of: searchString) { _ in
      clearSelectionIfNotDisplayable()
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
