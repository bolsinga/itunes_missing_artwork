//
//  Array+MissingArtwork.swift
//
//
//  Created by Greg Bolsinga on 2/4/23.
//

import Foundation

extension MissingArtwork {
  fileprivate func matches(_ string: String) -> Bool {
    string.isEmpty || description.localizedCaseInsensitiveContains(string)
  }
}

extension Array where Element == MissingArtwork {
  func filterForDisplay(
    availabilityFilter: AvailabilityCategory, searchString: String, sortOrder: SortOrder
  ) -> [MissingArtwork] {
    return self.filter { missingArtwork in
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
    }
    .filter { missingArtwork in
      missingArtwork.matches(searchString)
    }.sorted(by: sortOrder)
  }

  func sorted(by sortOrder: SortOrder) -> [MissingArtwork] {
    return self.sorted {
      switch sortOrder {
      case .ascending:
        return $0 < $1
      case .descending:
        return $1 < $0
      }
    }
  }
}
