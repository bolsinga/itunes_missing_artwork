//
//  Error+LocalizedError.swift
//
//
//  Created by Greg Bolsinga on 1/16/23.
//

import Foundation

private enum FallbackLocalizedError: Error {
  case fallback(Error)
}

extension FallbackLocalizedError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .fallback(let error):
      return error.localizedDescription
    }
  }
}

extension Error {
  var fallbackLocalizedError: LocalizedError {
    if let localizedError = self as? LocalizedError {
      return localizedError
    }
    return FallbackLocalizedError.fallback(self)
  }
}
