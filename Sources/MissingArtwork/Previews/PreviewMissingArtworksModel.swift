//
//  PreviewMissingArtworksModel.swift
//  itunes_missing_artwork
//
//  Created by Greg Bolsinga on 11/8/24.
//

extension MissingArtworksModel {
  enum LoaderResult<R> {
    case nothing
    case result(R)
    case error(Error)
  }

  @MainActor
  convenience init(
    missingArtworks: [MissingArtwork] = [],
    catalogArtworks: [MissingArtwork: [C]] = [:],
    artworkImages: [C: PlatformImage] = [:],
    partialLibraryImages: [MissingArtwork: PlatformImage] = [:],
    catalogLoaderResult: LoaderResult<[C]> = .nothing,
    artworkLoaderResult: LoaderResult<PlatformImage> = .result(previewImage)
  ) {
    self.init(
      missingArtworks: missingArtworks, catalogArtworks: catalogArtworks,
      artworkImages: artworkImages, artworkErrors: [],
      partialLibraryImages: partialLibraryImages,
      catalogLoader: { _ in
        switch catalogLoaderResult {
        case .nothing: return nil
        case .result(let r): return r
        case .error(let error): throw error
        }
      },
      artworkLoader: { _ in
        switch artworkLoaderResult {
        case .nothing: return nil
        case .result(let r): return r
        case .error(let error): throw error
        }
      })
  }
}
