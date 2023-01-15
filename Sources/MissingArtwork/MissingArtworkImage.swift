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
  let width: CGFloat

  @Binding var artworkImage: ArtworkImage

  private var artwork: Artwork {
    artworkImage.artwork
  }

  private var loadingState: LoadingState<NSImage> {
    artworkImage.loadingState
  }

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
      guard case .idle = loadingState else {
        return
      }

      artworkImage.loadingState = .loading

      do {
        guard let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight)
        else { throw NoImageError.noURL(artwork) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let nsImage = NSImage.init(data: data)

        if let nsImage {
          artworkImage.loadingState = .loaded(nsImage)
        } else {
          throw NoImageError.noImage(artwork)
        }
      } catch {
        artworkImage.loadingState = .error(error)
      }
    }
  }
}
