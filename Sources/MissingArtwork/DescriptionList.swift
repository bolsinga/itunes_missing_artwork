//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import SwiftUI

struct DescriptionList<C: ArtworkProtocol>: View {
  @State private var sortOrder = SortOrder.ascending
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var selectedArtworks: Set<MissingArtwork> = []

  @State private var searchString: String = ""

  @State private var selectedArtwork: C?

  let missingArtworksLoading: Bool

  @Binding var processingStates: [MissingArtwork: ProcessingState]

  var model: MissingArtworksModel<C>

  var missingArtworks: [MissingArtwork] {
    model.missingArtworks
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

  private var noArtSelectedArtworksCatalogArtworks: [MissingArtwork: [PlatformImage]] {
    noArtSelectedArtworks.reduce(
      into: [MissingArtwork: [PlatformImage]](),
      { partialResult, missingArtwork in
        partialResult[missingArtwork] = model.catalogArtworks[missingArtwork]?.filter {
          $0 == selectedArtwork
        }.compactMap { model.artworkImages[$0] }
      })
  }

  private var noArtSelectedArtworksWithImage: [(MissingArtwork, PlatformImage)] {
    noArtSelectedArtworksCatalogArtworks.flatMap { missingArtwork, images in
      images.map { (missingArtwork, $0) }
    }
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
    if missingArtworksLoading {
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
      .focusedSceneValue(\.partialArtworks, partialSelectedArtworksNotProcessed)
      .focusedSceneValue(\.noArtworks, noArtSelectedArtworksWithImageNotProcessed)
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
    @Bindable var bindableModel = model
    NavigationSplitView {
      sidebarView
        .frame(minWidth: 325)
        .filtersToolbar(
          availabilityFilter: $availabilityFilter, sortOrder: $sortOrder,
          dataSource: $bindableModel.dataSource)
    } detail: {
      DetailView(
        missingArtworks: missingArtworks,
        model: model,
        selectedArtworks: selectedArtworks,
        selectedArtwork: $selectedArtwork,
        processingStates: $processingStates,
        sortOrder: sortOrder)
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

#Preview("Loaded Two Missing Artworks - no selection") {
  let missingArtworks = [
    MissingArtwork.ArtistAlbum("The Stooges", "Fun House", .none),
    MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1", .some),
  ]
  return DescriptionList(
    missingArtworksLoading: false,
    processingStates: .constant(
      missingArtworks.reduce(into: [MissingArtwork: ProcessingState]()) {
        $0[$1] = .processing
      }
    ), model: MissingArtworksModel<PreviewArtwork>(missingArtworks: missingArtworks)
  )
}
#Preview("Loaded - No Missing Artworks") {
  DescriptionList(
    missingArtworksLoading: false, processingStates: .constant([:]),
    model: MissingArtworksModel<PreviewArtwork>())
}
#Preview("Loading") {
  DescriptionList(
    missingArtworksLoading: true, processingStates: .constant([:]),
    model: MissingArtworksModel<PreviewArtwork>())
}
