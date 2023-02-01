//
//  WrappedLocalizedError.swift
//
//
//  Created by Greg Bolsinga on 1/22/23.
//

import Foundation

public enum WrappedLocalizedError: LocalizedError {
  case localized(LocalizedError)

  public var errorDescription: String? {
    switch self {
    case .localized(let error):
      return error.errorDescription
    }
  }

  public var failureReason: String? {
    switch self {
    case .localized(let error):
      return error.failureReason
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .localized(let error):
      return error.recoverySuggestion
    }
  }

  public var helpAnchor: String? {
    switch self {
    case .localized(let error):
      return error.helpAnchor
    }
  }

  public static func wrapError(error: Error) -> WrappedLocalizedError {
    // This wrapping WrappedLocalizedError is necessary, as there is a compiler error if this
    // attempts to return LocalizedError? and the associated value is also LocalizedError.
    // So it is wrapped in a concrete type to hide this. Definitely not ideal, but can be
    // revisited in the future.
    if let localizedError = error as? LocalizedError {
      return WrappedLocalizedError.localized(localizedError)
    } else {
      return WrappedLocalizedError.localized(error.fallbackLocalizedError)
    }
  }
}
