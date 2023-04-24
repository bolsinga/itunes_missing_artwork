//
//  ProcessingState+Image.swift
//
//
//  Created by Greg Bolsinga on 2/8/23.
//

import SwiftUI

extension ProcessingState {
  @ViewBuilder var representingView: some View {
    if case .processing = self {
      Image(systemName: "gearshape.circle")
        .imageScale(.large)
        .help(
          Text(
            "Fixing Album", bundle: .module,
            comment: "Help string shown when album artwork is in the process of being fixed."))
    } else if case .success = self {
      Image(systemName: "checkmark.circle")
        .imageScale(.large)
        .foregroundColor(.green)
        .help(
          Text(
            "Fixed Album", bundle: .module,
            comment: "Help string shown when album artwork has been fixed."))
    } else if case .failure = self {
      Image(systemName: "circle.slash")
        .imageScale(.large)
        .foregroundColor(.red)
        .help(
          Text(
            "Unable to Fix Album", bundle: .module,
            comment: "Help string shown when album artwork failed to be fixed."))
    }
  }
}
