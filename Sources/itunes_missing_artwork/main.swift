import Foundation
import CupertinoJWT
import ArgumentParser

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
                let imageURLs = session.imageURLs(searchURL: searchURL)
                print("media: \(missingMediaArtwork) imageURLs: \(String(describing: imageURLs))")
            }
        }
    }
}

Generate.main()
