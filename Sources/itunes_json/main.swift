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
    private var simpleRepresentation : String {
        switch self {
        case let .ArtistAlbum(artist, album):
            return "\(artist) \(album)"
        case let .CompilationAlbum(title):
            return title
        }
    }

    var searchQueryRepresentation : String {
        return self.simpleRepresentation.replacingOccurrences(of: " ", with: "+")
    }

    var fileNameRepresentation : String {
        self.simpleRepresentation.replacingOccurrences(of: " ", with: "_")
    }
}

guard let itunes = try? ITLibrary(apiVersion: "1.0") else {
    print("No iTunes Library")
    exit(1)
}

let missingMediaArtworks = Set<MissingArtwork>(itunes.allMediaItems.compactMap {
                                                ((!$0.hasArtworkAvailable || $0.artwork == nil) && $0.mediaKind != .kindBook && $0.mediaKind != .kindVoiceMemo) ? $0.album.isCompilation ? .CompilationAlbum($0.album.title!) : .ArtistAlbum($0.artist?.name ?? $0.album.albumArtist!, $0.album.title ?? $0.title) : nil })

print("\(missingMediaArtworks.count) Missing Artworks:")
missingMediaArtworks.sorted().forEach { print("\($0.searchQueryRepresentation)") }
