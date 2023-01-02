//
//  MissingArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/8/22.
//

@preconcurrency import Foundation
import MusicKit
import SwiftUI

private enum NoImageError: Error {
  case noURL(Artwork)
  case noImage(Artwork)
}

extension NoImageError: LocalizedError {
  fileprivate var errorDescription: String? {
    switch self {
    case .noURL(let artwork):
      return "No Image URL Available: \(artwork.description)."
    case .noImage(let artwork):
      return "No Image Found: \(artwork.description)."
    }
  }
}

struct MissingArtworkImage: View {
  fileprivate enum LoadingState {
    case none
    case loading
    case error(Error)
    case loaded(NSImage)
  }

  let artwork: Artwork
  let width: CGFloat

  @Binding var nsImage: NSImage?

  @State private var loadingState: LoadingState = .none

  var body: some View {
    Group {
      switch loadingState {
      case .none:
        ProgressView()
      case .loading:
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
      loadingState = .loading

      do {
        guard let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight)
        else { throw NoImageError.noURL(artwork) }

        let (data, _) = try await URLSession.shared.data(from: url)
        nsImage = NSImage.init(data: data)

        if let nsImage = nsImage {
          loadingState = .loaded(nsImage)
        } else {
          throw NoImageError.noImage(artwork)
        }
      } catch {
        loadingState = .error(error)
      }
    }
  }
}
