//
//  MissingArtworkData.swift
//
//
//  Created by Greg Bolsinga on 5/23/22.
//

import Foundation

extension MissingArtwork {
  public static let previewArtworks = [
    MissingArtwork.ArtistAlbum("The Stooges", "Fun House"),
    MissingArtwork.CompilationAlbum("Beleza Tropical: Brazil Classics 1"),
  ]

  public static let previewArtworkURLs =
    [
      [
        URL(
          string:
            "https://is4-ssl.mzstatic.com/image/thumb/Music125/v4/21/57/95/2157956a-ab62-251e-f9f2-6c7eca9e52b9/mzi.tsrsdbxh.jpg/901x900bb.jpg"
        )!,
        URL(
          string:
            "https://is3-ssl.mzstatic.com/image/thumb/Music5/v4/70/00/e3/7000e319-5087-1bfb-6f1b-d975ec54f875/163_Superchunk_ComePickMeUp_2500px.jpg/2500x2500bb.jpg"
        )!,
      ],
      [
        URL(
          string:
            "https://is3-ssl.mzstatic.com/image/thumb/Music124/v4/e4/56/8d/e4568db1-d583-4456-7d44-e557fd887538/mzi.ritwbkcw.jpg/1425x1425bb.jpg"
        )!
      ],
    ]

  public static let previewArtworkHashURLs = [
    previewArtworks.first!: previewArtworkURLs.first!,
    previewArtworks.last!: previewArtworkURLs.last!,
  ]
}
