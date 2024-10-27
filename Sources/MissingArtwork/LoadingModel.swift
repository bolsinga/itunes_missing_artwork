//
//  LoadingModel.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 10/26/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let loadingModel = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "loadingModel")
}

@Observable final class LoadingModel<T, C> {
  typealias Loader = (C?) async -> (T?, Error?)
  var value: T?
  var error: Error?
  let loader: Loader

  public init(item: T? = nil, error: Error? = nil, loader: @escaping Loader = { _ in (nil, nil) }) {
    self.value = item
    self.error = error
    self.loader = loader
  }

  @MainActor
  public func load(_ context: C? = nil) async {
    let (value, error) = await loader(context)
    Logger.loadingModel.log("Loaded: \(String(describing: value), privacy: .public)")
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
