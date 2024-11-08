//
//  MissingArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/8/22.
//

import MusicKit
import SwiftUI

// Created so Previews may use fake Artwork.
protocol MissingArtworkProtocol: Hashable, Sendable {
  var backgroundColor: CGColor? { get }
  var maximumHeight: Int { get }
}

extension Artwork: MissingArtworkProtocol {}

struct MissingArtworkImage<C: MissingArtworkProtocol>: View {
  let width: CGFloat

  let artwork: C
  var loadingState: LoadingModel<PlatformImage, C>

  var body: some View {
    Group {
      if loadingState.isIdleOrLoading {
        ZStack {
          if let backgroundColor = artwork.backgroundColor {
            Color(cgColor: backgroundColor)
              .frame(width: width, height: CGFloat(artwork.maximumHeight))
          }
          ProgressView()
        }
      } else if let error = loadingState.error {
        Text(
          "Unable to load image: \(error.localizedDescription)", bundle: .module,
          comment: "Message when an image URL cannot be loaded.")
      } else if let platformImage = loadingState.value {
        platformImage.representingImage
          .resizable().aspectRatio(contentMode: .fit)
      }
    }
    .frame(width: width)
    .task { await loadingState.load(artwork) }
  }
}

private struct PreviewArtwork: MissingArtworkProtocol {
  var backgroundColor: CGColor?
  var maximumHeight: Int { 300 }

  internal init(backgroundColor: CGColor? = CGColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)) {
    self.backgroundColor = backgroundColor
  }
}

#Preview("Loading - No Background Color") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(backgroundColor: nil), loadingState: LoadingModel()
  )
  .frame(width: 300, height: 300)
}

#Preview("Loading - Background Color") {
  MissingArtworkImage(width: 300, artwork: PreviewArtwork(), loadingState: LoadingModel())
    .frame(width: 300, height: 300)
}

#Preview("Error") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(), loadingState: LoadingModel(error: CancellationError())
  )
  .frame(width: 300, height: 300)
}

#if canImport(UIKit)
  private let image = UIImage(systemName: "pencil.circle")
#else
  private let image = NSImage(systemSymbolName: "pencil.circle", accessibilityDescription: nil)
#endif

#Preview("Image") {
  MissingArtworkImage(
    width: 300, artwork: PreviewArtwork(),
    loadingState: LoadingModel(item: PlatformImage(image: image!))
  )
  .frame(width: 300, height: 300)
}
