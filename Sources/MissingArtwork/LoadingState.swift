//
//  LoadingState.swift
//
//
//  Created by Greg Bolsinga on 1/14/23.
//

import Foundation

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

  public var currentError: WrappedLocalizedError? {
    if case .error(let error) = self {
      return WrappedLocalizedError.wrapError(error: error)
    }
    return nil
  }
}
