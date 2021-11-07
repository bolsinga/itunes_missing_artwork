//
//  ArtworkURLFecther.swift
//  
//
//  Created by Greg Bolsinga on 11/6/21.
//

import Foundation

fileprivate struct Artwork : Codable {
    var width : Int
    var height : Int
    var url : String
}

fileprivate struct MusicResponse : Codable {
    struct Results : Codable {
        struct Album : Codable {
            struct Data : Codable {
                struct Attributes : Codable {
                    var artwork : Artwork
                }
                var attributes : Attributes
            }
            var data : [Data]
        }
        var albums : Album
    }
    var results : Results
}

fileprivate extension Artwork {
    var imageURL : URL? {
        return URL(string: url.replacingOccurrences(of: "{w}", with: "\(width)").replacingOccurrences(of: "{h}", with: "\(height)"))
    }
}

struct ArtworkURLFecther {
    let session : URLSession
 
    public init(_ session: URLSession) {
        self.session = session;
    }
    
    public func fetch(_ searchURL: URL) async throws -> [URL] {
        let (data, _) = try await self.session.data(from: searchURL) // wait for the data
        let music = try JSONDecoder().decode(MusicResponse.self, from: data) // decode the data
        return music.results.albums.data.compactMap { $0.attributes.artwork.imageURL } // Convert the array of results into an array of URLs
    }
}
