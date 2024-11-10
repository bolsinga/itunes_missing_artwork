//
//  PreviewImage.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 11/8/24.
//

import SwiftUI

#if canImport(UIKit)
  private let image = UIImage(systemName: "pencil.circle")
#else
  @MainActor private let image = NSImage(
    systemSymbolName: "pencil.circle", accessibilityDescription: nil)
#endif

@MainActor let previewImage = PlatformImage(image: image!)
