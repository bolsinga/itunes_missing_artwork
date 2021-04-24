import Foundation
import CupertinoJWT
import ArgumentParser
import Combine

extension MissingArtwork {
    var searchURL : URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.music.apple.com"
        urlComponents.path = "/v1/catalog/us/search"
        urlComponents.queryItems = [URLQueryItem(name: "term", value: self.simpleRepresentation),
                                    URLQueryItem(name: "types", value: "albums"),
                                    URLQueryItem(name: "limit", value: "2")]
        return urlComponents.url
    }
}

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

var semaphore = DispatchSemaphore(value: 0)

struct Generate : ParsableCommand {
    struct SigningData : ExpressibleByArgument {
        var p8 : String

        init?(argument: String) {
            do {
                p8 = try String(contentsOf: URL(fileURLWithPath: argument))
            } catch {
                return nil
            }
        }
    }

    @Option(help: "The keyID for the JWT")
    var keyID: String

    @Option(help: "The teamID for the JWT")
    var teamID: String

    @Argument(help: "The path to the p8 file")
    var signingData: SigningData

    func run() throws {
        let token = try JWT(keyID: keyID, teamID: teamID, issueDate: Date(), expireDuration: 60 * 60).sign(with: signingData.p8)

        let missingMediaArtworks = try MissingArtwork.gatherMissingArtwork()
        print("\(missingMediaArtworks.count) Missing Artworks")

        let sessionConfiguration = URLSessionConfiguration.default;
        sessionConfiguration.httpAdditionalHeaders = [ "Authorization" : "Bearer \(token)"]

        let session = URLSession(configuration: sessionConfiguration)

        for missingMediaArtwork in missingMediaArtworks.sorted() {
            if let searchURL = missingMediaArtwork.searchURL {
            let cancellable = session.dataTaskPublisher(for: searchURL)
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
                                print("media: \(missingMediaArtwork) \(index) url: \(url.absoluteString)")
                            } else {
                                print("media: \(missingMediaArtwork) \(index) invalid artwork: \(artwork)")
                            }
                            index += 1
                        }
                    } catch {
                        print("media: \(missingMediaArtwork) invalid decode: \(String(describing: String(data: receivedValue.data, encoding: .utf8)))")
                    }
                }
                semaphore.wait()
            }
        }
    }
}

Generate.main()
