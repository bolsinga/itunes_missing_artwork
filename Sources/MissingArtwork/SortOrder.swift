//
//  SortOrder.swift
//
//
//  Created by Greg Bolsinga on 2/4/23.
//

import Foundation

enum SortOrder: String, CaseIterable, Identifiable {
  case ascending = "Ascending"
  case descending = "Descending"

  var id: SortOrder { self }
}
