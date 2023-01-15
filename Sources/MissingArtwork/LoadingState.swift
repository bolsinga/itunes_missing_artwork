//
//  LoadingState.swift
//
//
//  Created by Greg Bolsinga on 1/14/23.
//

import Foundation

enum LoadingState<Value> {
  case idle
  case loading
  case error(Error)
  case loaded(Value)

  var value: Value? {
    if case .loaded(let value) = self {
      return value
    }
    return nil
  }

  var isIdleOrLoading: Bool {
    switch self {
    case .idle, .loading:
      return true
    case .error(_), .loaded(_):
      return false
    }
  }
}
