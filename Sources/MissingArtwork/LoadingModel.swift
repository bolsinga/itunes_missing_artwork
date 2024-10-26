//
//  LoadingModel.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 10/26/24.
//

import Foundation

@Observable final class LoadingModel<T> {
  typealias Loader = () async -> (T?, Error?)
  var value: T?
  var error: Error?
  let loader: Loader

  public init(item: T? = nil, error: Error? = nil, loader: @escaping Loader = { (nil, nil) }) {
    self.value = item
    self.error = error
    self.loader = loader
  }

  @MainActor
  public func load() async {
    let (value, error) = await loader()
    if let value {
      self.value = value
    } else {
      self.error = error
    }
  }

  var isError: Bool { error != nil }

  var currentError: WrappedLocalizedError? {
    guard let error else { return nil }
    return WrappedLocalizedError.wrapError(error: error)
  }

  public var isIdleOrLoading: Bool {
    value == nil && error == nil
  }
}
