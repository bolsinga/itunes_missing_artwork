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
}
