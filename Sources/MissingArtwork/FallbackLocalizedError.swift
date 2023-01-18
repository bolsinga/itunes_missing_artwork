//
//  FallbackLocalizedError.swift
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
    // So SwiftUI .alert takes a LocalizedError. However Swift do / try / catch
    // generically just catches Error. The Error.localizedDescription method exists,
    // but it is not a LocalizedError, so SwiftUI does not care for it. This code is
    // just a way to work around this quirk. This can be revisited in the future as well.
    if let localizedError = self as? LocalizedError {
      return localizedError
    }
    return FallbackLocalizedError.fallback(self)
  }
}
