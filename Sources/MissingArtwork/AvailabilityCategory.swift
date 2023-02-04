//
//  AvailabilityCategory.swift
//
//
//  Created by Greg Bolsinga on 2/4/23.
//

import Foundation

enum AvailabilityCategory: String, CaseIterable, Identifiable {
  case all = "All"
  case none = "No Artwork"
  case partial = "Partial Artwork"
  case unknown = "Unknown"

  var id: AvailabilityCategory { self }
}
