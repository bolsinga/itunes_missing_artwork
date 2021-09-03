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
        let cancellable = self.dataTaskPublisher(for: searchURL)
        .sink { completion in
            switch completion {
            case let .failure(reason):
                print("failed: \(reason)")
            case .finished:
                semaphore.signal()
                break
            }
        } receiveValue: { receivedValue in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let musicResponse = try decoder.decode(MusicResponse.self, from: receivedValue.data)
                var index = 0
                for data in musicResponse.results.albums.data {
                    let artwork = data.attributes.artwork
                    if let url = artwork.imageURL {
                        urls.append(url)
                        print("\(index) url: \(url.absoluteString)")
                    } else {
                        print("\(index) invalid artwork: \(artwork)")
                    }
                    index += 1
                }
            } catch {
                print("invalid decode: \(String(describing: String(data: receivedValue.data, encoding: .utf8)))")
            }
        }
        semaphore.wait()
        return urls
    }
}
