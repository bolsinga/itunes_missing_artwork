//
//  DescriptionListFiltersToolbarModifier.swift
//
//
//  Created by Greg Bolsinga on 2/4/23.
//

import SwiftUI

struct DescriptionListFiltersToolbarModifier: ViewModifier {
  @Binding var availabilityFilter: AvailabilityCategory
  @Binding var sortOrder: SortOrder
  @Binding var dataSource: DataSource

  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem {
          Menu {
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
            #if canImport(iTunesLibrary)
              Picker(selection: $dataSource) {
                ForEach(DataSource.allCases) {
                  Text($0.rawValue).tag($0)
                }
              } label: {
                Text(
                  "Data Source", bundle: .module,
                  comment: "Shown to change the data source for the Missing Artwork.")
              }
            #endif
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
      }
  }
}

extension View {
  func filtersToolbar(
    availabilityFilter: Binding<AvailabilityCategory>, sortOrder: Binding<SortOrder>,
    dataSource: Binding<DataSource>
  ) -> some View {
    modifier(
      DescriptionListFiltersToolbarModifier(
        availabilityFilter: availabilityFilter, sortOrder: sortOrder, dataSource: dataSource))
  }
}
