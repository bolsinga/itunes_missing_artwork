//
//  Binding+OptionalDefaultValue.swift
//
//
//  Created by Greg Bolsinga on 1/21/23.
//

import SwiftUI

extension Binding {
  public func defaultValue<T>(_ value: T) -> Binding<T> where Value == T? {
    Binding<T> {
      wrappedValue ?? value
    } set: {
      wrappedValue = $0
    }
  }
}
