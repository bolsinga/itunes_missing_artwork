import ArgumentParser
import CupertinoJWT
import Foundation
import MissingArtwork

@main
struct Program: AsyncParsableCommand {
  struct SigningData: ExpressibleByArgument {
    var p8: String

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

  @MainActor
  mutating func run() async throws {
    let token = try JWT(keyID: keyID, teamID: teamID, issueDate: Date(), expireDuration: 60 * 60)
      .sign(with: signingData.p8)

    let model = Model()
    try await model.fetchMissingArtworks(token: token)
    let missingMediaArtworks = model.missingArtworks
    print("\(missingMediaArtworks.count) Missing Artworks")

    print("\(model.missingArtworkURLs)")
  }
}
