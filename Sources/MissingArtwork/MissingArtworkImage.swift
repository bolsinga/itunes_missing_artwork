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
  let artwork: Artwork
  let width: CGFloat

  @Binding var nsImage: NSImage?

  @State private var loadingState: LoadingState<NSImage> = .loading

  var body: some View {
    Group {
      if case .loading = loadingState {
        if let backgroundColor = artwork.backgroundColor {
          Color(cgColor: backgroundColor)
            .frame(width: width, height: CGFloat(artwork.maximumHeight))
        } else {
          ProgressView()
        }
      } else if case .error(let error) = loadingState {
        Text("Unable to load image: \(error.localizedDescription)")
      } else if case .loaded(let nsImage) = loadingState {
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
      guard nsImage == nil else {
        loadingState = .loaded(nsImage!)
        return
      }

      loadingState = .loading

      do {
        guard let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight)
        else { throw NoImageError.noURL(artwork) }

        let (data, _) = try await URLSession.shared.data(from: url)
        nsImage = NSImage.init(data: data)

        if let nsImage {
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
