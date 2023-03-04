//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import LoadingState
import MusicKit
import SwiftUI

struct DescriptionList: View {
  @State private var sortOrder = SortOrder.ascending
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var selectedArtworks: Set<MissingArtwork> = []

  @State private var searchString: String = ""

  @State private var selectedArtworkImages: [MissingArtwork: NSImage] = [:]
  @State private var artworkLoadingStates: [MissingArtwork: LoadingState<[ArtworkLoadingImage]>] =
    [:]

  @Binding var loadingState: LoadingState<[MissingArtwork]>

  @Binding var processingStates: [MissingArtwork: ProcessingState]

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
      availabilityFilter: availabilityFilter, searchString: searchString, sortOrder: sortOrder)
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
        .tag(missingArtwork)
      }
      .overlay(listStateOverlay)
      .searchable(text: $searchString) {
        ForEach(searchSuggestions) { suggestion in
          Text(suggestion.description).searchCompletion(suggestion.description)
        }
      }
      .focusedValue(
        \.partialArtworks, .constant(selectedArtworks.filter { $0.availability == .some })
      )
      .focusedValue(
        \.noArtworks,
        .constant(
          selectedArtworks.filter { $0.availability == .none }.filter {
            selectedArtworkImages[$0] != nil
          }.map { ($0, selectedArtworkImages[$0]!) }))
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
        .frame(minWidth: 325)
        .filtersToolbar(availabilityFilter: $availabilityFilter, sortOrder: $sortOrder)
    } detail: {
      DetailView(
        loadingState: $loadingState,
        artworkLoadingStates: $artworkLoadingStates,
        selectedArtworks: $selectedArtworks,
        selectedArtworkImages: $selectedArtworkImages,
        processingStates: $processingStates,
        sortOrder: $sortOrder)
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
    DescriptionList(
      loadingState: .constant(.loaded(missingArtworks)),
      processingStates: .constant(
        missingArtworks.reduce(into: [MissingArtwork: ProcessingState]()) {
          $0[$1] = .processing
        }
      )
    )

    DescriptionList(loadingState: .constant(.loaded([])), processingStates: .constant([:]))

    DescriptionList(loadingState: .constant(.loading), processingStates: .constant([:]))

    DescriptionList(loadingState: .constant(.idle), processingStates: .constant([:]))
  }
}
