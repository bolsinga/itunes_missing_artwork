//
//  FilterCategory.swift
//
//
//  Created by Greg Bolsinga on 2/4/23.
//

import Foundation

enum FilterCategory: String, CaseIterable, Identifiable {
  case all = "All"
  case albums = "Albums"
  case compilations = "Compliations"

  var id: FilterCategory { self }
}
