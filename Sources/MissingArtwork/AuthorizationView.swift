//
//  AuthorizationView.swift
//
//
//  Created by Greg Bolsinga on 6/14/22.
//

import MusicKit
import SwiftUI

struct AuthorizationView: View {
  @Binding var musicAuthorizationStatus: MusicAuthorization.Status

  var body: some View {
    VStack {
      Text("Missing Artwork")
        .font(.headline)
      explanatoryText
        .font(.caption)
      if musicAuthorizationStatus == .notDetermined {
        Button(action: handleButtonPressed) {
          buttonText
            .padding([.leading, .trailing], 10)
        }
      }
    }
    .frame(width: 300, height: 200)
  }

  private var explanatoryText: Text {
    let explanatoryText: Text
    switch musicAuthorizationStatus {
    case .restricted:
      explanatoryText =
        Text("Missing Artwork cannot be used because usage of ")
        + Text(Image(systemName: "applelogo")) + Text(" Music is restricted.")
    default:
      explanatoryText =
        Text("Missing Artwork uses ")
        + Text(Image(systemName: "applelogo")) + Text(" Music to find artwork images.")

    }
    return explanatoryText
  }

  private func handleButtonPressed() {
    switch musicAuthorizationStatus {
    case .notDetermined:
      Task {
        let musicAuthorizationStatus = await MusicAuthorization.request()
        await update(with: musicAuthorizationStatus)
      }
    default:
      fatalError(
        "No button should be displayed for current authorization status: \(musicAuthorizationStatus)."
      )
    }
  }

  private var buttonText: Text {
    let buttonText: Text
    switch musicAuthorizationStatus {
    case .notDetermined:
      buttonText = Text("Continue")
    default:
      fatalError(
        "No button should be displayed for current authorization status: \(musicAuthorizationStatus)."
      )
    }
    return buttonText
  }

  @MainActor
  private func update(with musicAuthorizationStatus: MusicAuthorization.Status) {
    withAnimation {
      self.musicAuthorizationStatus = musicAuthorizationStatus
    }
  }

  class PresentationCoordinator: ObservableObject {
    static let shared = PresentationCoordinator()

    private init() {
      let authorizationStatus = MusicAuthorization.currentStatus
      musicAuthorizationStatus = authorizationStatus
      isAuthorizationSheetPresented = (authorizationStatus != .authorized)
    }

    @Published var musicAuthorizationStatus: MusicAuthorization.Status {
      didSet {
        isAuthorizationSheetPresented = (musicAuthorizationStatus != .authorized)
      }
    }

    @Published var isAuthorizationSheetPresented: Bool
  }

  fileprivate struct SheetPresentationModifier: ViewModifier {
    @StateObject private var presentationCoordinator = PresentationCoordinator.shared

    func body(content: Content) -> some View {
      content
        .sheet(isPresented: $presentationCoordinator.isAuthorizationSheetPresented) {
          AuthorizationView(
            musicAuthorizationStatus: $presentationCoordinator.musicAuthorizationStatus
          )
          .interactiveDismissDisabled()
        }
    }
  }
}

extension View {
  @MainActor func musicKitAuthorizationSheet() -> some View {
    modifier(AuthorizationView.SheetPresentationModifier())
  }
}

struct AuthorizationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthorizationView(musicAuthorizationStatus: .constant(.authorized))
    AuthorizationView(musicAuthorizationStatus: .constant(.denied))
    AuthorizationView(musicAuthorizationStatus: .constant(.notDetermined))
    AuthorizationView(musicAuthorizationStatus: .constant(.restricted))
  }
}
