//
//  DescriptionList.swift
//
//
//  Created by Greg Bolsinga on 4/19/22.
//

import MusicKit
import SwiftUI

struct DescriptionList<NoArtworkContextMenuContent: View, PartialArtworkContextMenuContent: View>:
  View
{
  public typealias NoArtworkContextMenuBuilder = (
    [(missingArtwork: MissingArtwork, image: NSImage)]
  ) -> NoArtworkContextMenuContent
  public typealias PartialArtworkContextMenuBuilder = ([MissingArtwork]) ->
    PartialArtworkContextMenuContent

  @ViewBuilder let noArtworkContextMenuBuilder: NoArtworkContextMenuBuilder
  @ViewBuilder let partialArtworkContextMenuBuilder: PartialArtworkContextMenuBuilder

  @State private var sortOrder = SortOrder.ascending
  @State private var availabilityFilter = AvailabilityCategory.all

  @State private var selectedArtworks: Set<MissingArtwork> = []

  @State private var searchString: String = ""

  @State private var selectedArtworkImages: [MissingArtwork: NSImage] = [:]
  @State private var artworkLoadingStates:
    [MissingArtwork: LoadingState<[(Artwork, LoadingState<NSImage>)]>] = [:]

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
        .contextMenu {
          Menu {
            let noArtworkWithImages = selectedArtworks.filter { $0.availability == .none }.filter {
              selectedArtworkImages[$0] != nil
            }.map { ($0, selectedArtworkImages[$0]!) }
            if noArtworkWithImages.isEmpty {
              Text("No Images Selected", bundle: .module, comment: "Shown when context menu is being shown for No Artwork images and no artwork image has been selected.")
            } else {
              self.noArtworkContextMenuBuilder(noArtworkWithImages)
            }
          } label: {
            Text("No Artwork", bundle: .module, comment: "Label for the context menu grouping No Artwork actions.")
          }
          Menu {
            self.partialArtworkContextMenuBuilder(selectedArtworks.filter { $0.availability == .some })
          } label: {
            Text("Partial Artwork", bundle: .module, comment: "Label for the context menu grouping Partial Artwork actions.")
          }
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
    let fakeButton1Title = "1"
    let fakeButton2Title = "2"
    DescriptionList(
      noArtworkContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      partialArtworkContextMenuBuilder: { items in
        EmptyView()
      },
      loadingState: .constant(.loaded(missingArtworks)),
      processingStates: .constant(
        missingArtworks.reduce(into: [MissingArtwork: ProcessingState]()) {
          $0[$1] = .processing
        }
      )
    )

    DescriptionList(
      noArtworkContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      partialArtworkContextMenuBuilder: { items in
        EmptyView()
      },
      loadingState: .constant(.loaded([])),
      processingStates: .constant([:])
    )

    DescriptionList(
      noArtworkContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      partialArtworkContextMenuBuilder: { items in
        EmptyView()
      },
      loadingState: .constant(.loading),
      processingStates: .constant([:])
    )

    DescriptionList(
      noArtworkContextMenuBuilder: { items in
        Button(fakeButton1Title) {}
        Button(fakeButton2Title) {}
      },
      partialArtworkContextMenuBuilder: { items in
        EmptyView()
      },
      loadingState: .constant(.idle),
      processingStates: .constant([:])
    )
  }
}
