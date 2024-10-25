//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import SwiftUI

struct DescriptionList: View {
  @State private var sortOrder = SortOrder.ascending
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var selectedArtworks: Set<MissingArtwork> = []

  @State private var searchString: String = ""

  @State private var selectedArtworkImages: [MissingArtwork: ArtworkLoadingImage] = [:]
  @State private var artworkLoadingStates: [MissingArtwork: LoadingState<[ArtworkLoadingImage]>] =
    [:]

  @State private var partialArtworkImageLoadingStates:
    [MissingArtwork: LoadingState<PlatformImage>] = [:]

  let loadingState: LoadingState<[MissingArtwork]>

  @Binding var processingStates: [MissingArtwork: ProcessingState]

  var missingArtworks: [MissingArtwork] {
    loadingState.value ?? []
  }

  var missingArtworksIsEmpty: Bool {
    missingArtworks.isEmpty
  }

  var missingArtworksCount: Int {
    missingArtworks.count
  }

  var displayableArtworks: [MissingArtwork] {
    missingArtworks.filterForDisplay(
      availabilityFilter: availabilityFilter, searchString: searchString, sortOrder: sortOrder)
  }

  private var partialSelectedArtworks: [MissingArtwork] {
    selectedArtworks.filter { $0.availability == .some }
  }

  private var partialSelectedArtworksNotProcessed: [MissingArtwork] {
    partialSelectedArtworks.filter { processingStates[$0] == nil || processingStates[$0]! == .none }
  }

  private var noArtSelectedArtworks: [MissingArtwork] {
    selectedArtworks.filter { $0.availability == .none }
  }

  private var noArtSelectedArtworksContainingSelectedImage: [MissingArtwork] {
    noArtSelectedArtworks.filter { selectedArtworkImages[$0] != nil }
  }

  private var noArtSelectedArtworksContainingSelectedArtworkLoadingImage:
    [(MissingArtwork, ArtworkLoadingImage)]
  {
    noArtSelectedArtworksContainingSelectedImage.map { ($0, selectedArtworkImages[$0]!) }
  }

  private var noArtSelectedArtworksContainingSelectedAndLoadedImage:
    [(MissingArtwork, ArtworkLoadingImage)]
  {
    noArtSelectedArtworksContainingSelectedArtworkLoadingImage.filter {
      $1.loadingState.value != nil
    }
  }

  private var noArtSelectedArtworksWithImage: [(MissingArtwork, PlatformImage)] {
    noArtSelectedArtworksContainingSelectedAndLoadedImage.map { ($0, $1.loadingState.value!) }
  }

  private var noArtSelectedArtworksWithImageNotProcessed: [(MissingArtwork, PlatformImage)] {
    noArtSelectedArtworksWithImage.filter {
      processingStates[$0.0] == nil || processingStates[$0.0]! == .none
    }
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

  @MainActor
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
      .focusedSceneValue(\.partialArtworks, .constant(partialSelectedArtworksNotProcessed))
      .focusedSceneValue(\.noArtworks, .constant(noArtSelectedArtworksWithImageNotProcessed))
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
        missingArtworks: missingArtworks,
        artworkLoadingStates: $artworkLoadingStates,
        selectedArtworks: selectedArtworks,
        selectedArtworkImages: $selectedArtworkImages,
        processingStates: $processingStates,
        sortOrder: sortOrder,
        partialArtworkImageLoadingStates: $partialArtworkImageLoadingStates)
    }.onChange(of: availabilityFilter) { _, _ in
      clearSelectionIfNotDisplayable()
    }.onChange(of: searchString) { _, _ in
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
      loadingState: .loaded(missingArtworks),
      processingStates: .constant(
        missingArtworks.reduce(into: [MissingArtwork: ProcessingState]()) {
          $0[$1] = .processing
        }
      )
    )

    DescriptionList(loadingState: .loaded([]), processingStates: .constant([:]))

    DescriptionList(loadingState: .loading, processingStates: .constant([:]))

    DescriptionList(loadingState: .idle, processingStates: .constant([:]))
  }
}
