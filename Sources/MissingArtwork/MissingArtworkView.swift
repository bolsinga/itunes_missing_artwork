//
//  MissingArtworkView.swift
//
//
//  Created by Greg Bolsinga on 5/28/22.
//

import SwiftUI

public struct MissingArtworkView: View {
  let token: String

  public init(token: String) {
    self.token = token
  }

  public var body: some View {
    DescriptionList(token: token)
  }
}

struct MissingArtworkView_Previews: PreviewProvider {
  static var previews: some View {
    MissingArtworkView(token: "")
  }
}
