//
//  MissingArtwork.swift
//
//
//  Created by Greg Bolsinga on 3/28/21.
//

import Foundation
import iTunesLibrary

enum MissingArtwork : Hashable, Comparable {
    case ArtistAlbum(String, String)
    case CompilationAlbum(String)
}

extension MissingArtwork : CustomStringConvertible {
    var description : String {
        switch self {
        case let .ArtistAlbum(artist, album):
            return "\(artist): \(album)"
        case let .CompilationAlbum(title):
            return "\(title)"
        }
    }
}

extension MissingArtwork {
    var simpleRepresentation : String {
        switch self {
        case let .ArtistAlbum(artist, album):
            return "\(artist) \(album)"
        case let .CompilationAlbum(title):
            return title
        }
    }

    var fileNameRepresentation : String {
        self.simpleRepresentation.replacingOccurrences(of: " ", with: "_")
    }

    static func gatherMissingArtwork() throws -> Set<MissingArtwork> {
        let itunes = try ITLibrary(apiVersion: "1.0")

        let items : [MissingArtwork] = itunes.allMediaItems
            .filter { $0.mediaKind != .kindBook }
            .filter { $0.mediaKind != .kindVoiceMemo }
            .filter { !$0.hasArtworkAvailable || $0.artwork == nil }
            .compactMap {
                $0.album.isCompilation ? .CompilationAlbum($0.album.title!)
                    : .ArtistAlbum($0.artist?.name ?? $0.album.albumArtist!, $0.album.title ?? $0.title)
            }

        return Set<MissingArtwork>(items)
    }
}
