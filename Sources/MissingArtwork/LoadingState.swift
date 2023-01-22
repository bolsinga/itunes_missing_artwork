//
//  LoadingState.swift
//
//
//  Created by Greg Bolsinga on 1/14/23.
//

import Foundation

public enum LoadingStateError: LocalizedError {
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
}

public enum LoadingState<Value> {
  case idle
  case loading
  case error(Error)
  case loaded(Value)

  public var value: Value? {
    if case .loaded(let value) = self {
      return value
    }
    return nil
  }

  public var isIdleOrLoading: Bool {
    switch self {
    case .idle, .loading:
      return true
    case .error(_), .loaded(_):
      return false
    }
  }

  public var isError: Bool {
    if case .error(_) = self {
      return true
    }
    return false
  }

  public var currentError: LoadingStateError? {
    // This wrapping LoadingStateError is necessary, as there is a compiler error if this
    // attempts to return LocalizedError? and the associated value is also LocalizedError.
    // So it is wrapped in a concrete type to hide this. Definitely not ideal, but can be
    // revisited in the future.
    if case .error(let error) = self {
      if let localizedError = error as? LocalizedError {
        return LoadingStateError.localized(localizedError)
      } else {
        return LoadingStateError.localized(error.fallbackLocalizedError)
      }
    }
    return nil
  }
}
