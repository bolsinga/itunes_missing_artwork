//
//  URLSession+MusicAPI.swift
//  
//
//  Created by Greg Bolsinga on 9/3/21.
//

import Foundation
import Combine

struct Artwork : Codable {
    var width : Int
    var height : Int
    var url : String
}

struct MusicResponse : Codable {
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

extension Artwork {
    var imageURL : URL? {
        return URL(string: url.replacingOccurrences(of: "{w}", with: "\(width)").replacingOccurrences(of: "{h}", with: "\(height)"))
    }
}

extension URLSession {
    func imageURLs(searchURL: URL) -> [URL] {
        var urls : [URL] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        
        // TODO: figure out how to make a closure to just pass this to the decoder parameter below.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let cancellable = self.dataTaskPublisher(for: searchURL)
            .map { $0.data } // Get the Data
            .decode(type: MusicResponse.self, decoder: decoder) // Decode the JSON
            .map { $0.results.albums.data.compactMap { $0.attributes.artwork.imageURL } } // Convert the array of results into an array of URLs
            .sink { completion in
                switch completion {
                case let .failure(reason):
                    print("failed: \(reason)")
                case .finished:
                    break
                }
                semaphore.signal()
            } receiveValue: { url in
                urls.append(contentsOf: url)
            }
        semaphore.wait()
        return urls
    }
}
