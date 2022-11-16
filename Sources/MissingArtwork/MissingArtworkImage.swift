//
//  MissingArtworkImage.swift
//
//
//  Created by Greg Bolsinga on 11/8/22.
//

@preconcurrency import Foundation
import AppKit
import MusicKit
import SwiftUI

struct MissingArtworkImage: View {
  let artwork: Artwork
  let width: CGFloat

  @State private var nsImage: NSImage? = nil
  @State private var showProgressOverlay: Bool = true
  @State private var error: Error? = nil

  @ViewBuilder private var overlay: some View {
    if showProgressOverlay {
      if let backgroundColor = artwork.backgroundColor {
        Color(cgColor: backgroundColor)
          .frame(width: width, height: CGFloat(artwork.maximumHeight))
      } else {
        ProgressView()
      }
    } else if let error = error {
      Text("Unable to load image: \(error.localizedDescription)")
    }
  }

  var body: some View {
    if let url = artwork.url(width: artwork.maximumWidth, height: artwork.maximumHeight) {
      Group {
        if let nsImage = nsImage {
          Image(nsImage: nsImage)
            .resizable().aspectRatio(contentMode: .fit)
        } else {
          Text("Loading!")
        }
      }
      .overlay(self.overlay)
      .frame(width: width)
      .task {
        showProgressOverlay = true
        defer {
          showProgressOverlay = false
        }

        do {
          let (data, _) = try await URLSession.shared.data(from: url)
          nsImage = NSImage.init(data: data)
        } catch {
          self.error = error
        }
      }
    } else {
      Text("Unable to get URL for Artwork")
    }
  }
}
