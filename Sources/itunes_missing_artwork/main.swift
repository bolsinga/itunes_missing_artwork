import Foundation
import CupertinoJWT
import ArgumentParser
import Combine

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

        var cancellables : [AnyCancellable] = []

        for missingMediaArtwork in missingMediaArtworks.sorted() {
            let cancellable = session.musicAPIImageURLPublisher(searchURL: missingMediaArtwork.searchURL)
                .sink { completion in
                    switch completion {
                    case let .failure(reason):
                        print("media: \(missingMediaArtwork) failed: \(reason)")
                    case .finished:
                        break
                    }
                } receiveValue: { urls in
                    print("media: \(missingMediaArtwork) imageURLs: \(String(describing: urls))")
                }

            cancellables.append(cancellable)
        }

        RunLoop.main.run()
    }
}

Generate.main()
