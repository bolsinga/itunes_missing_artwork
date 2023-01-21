//
//  MissingArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/8/22.
//

import MusicKit
import SwiftUI

struct MissingArtworkImage: View {
  let width: CGFloat

  let artwork: Artwork
  @Binding var loadingState: LoadingState<NSImage>

  var body: some View {
    Group {
      switch loadingState {
      case .idle, .loading:
        if let backgroundColor = artwork.backgroundColor {
          Color(cgColor: backgroundColor)
            .frame(width: width, height: CGFloat(artwork.maximumHeight))
        } else {
          ProgressView()
        }
      case .error(let error):
        Text("Unable to load image: \(error.localizedDescription)")
      case .loaded(let nsImage):
        Image(nsImage: nsImage)
          .resizable().aspectRatio(contentMode: .fit)
          .contextMenu {
            Button("Copy") {
              let pasteboard = NSPasteboard.general
              pasteboard.clearContents()
              pasteboard.writeObjects([nsImage])
            }
          }
      }
    }
    .frame(width: width)
    .task {
      await loadingState.load(artwork: artwork)
    }
  }
}
