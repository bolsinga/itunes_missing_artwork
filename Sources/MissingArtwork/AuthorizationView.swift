//
//  AuthorizationView.swift
//
//
//  Created by Greg Bolsinga on 6/14/22.
//

import MusicKit
import SwiftUI

extension Bundle {
  fileprivate var applicationName: String {
    object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(
      forInfoDictionaryKey: "CFBundleName") as? String ?? ""
  }
}

struct AuthorizationView: View {
  @Binding var musicAuthorizationStatus: MusicAuthorization.Status

  private var applicationName: String {
    Bundle.main.applicationName
  }

  var body: some View {
    VStack {
      Spacer()
      Text(applicationName)
        .font(.title)
      Divider()
      explanatoryText
        .font(.body)
      if musicAuthorizationStatus == .notDetermined {
        Spacer()
        Button(action: handleButtonPressed) {
          buttonText
            .padding([.leading, .trailing], 10)
        }
        Spacer()
      }
    }
    .padding()
  }

  private var explanatoryText: Text {
    let explanatoryText: Text
    switch musicAuthorizationStatus {
    case .restricted:
      explanatoryText =
        Text(
          "\(applicationName) cannot be used because usage of Apple Music is restricted.",
          bundle: .module,
          comment:
            "Shown when application was not granted access to MusicKit. Variable is the application name."
        )
    default:
      explanatoryText =
        Text(
          """
          **\(applicationName)** uses Apple Music to find artwork images.
          * Partial Artwork is when some of the tracks of an album have artwork. These can be fixed right away.
          * No Artwork is when none of the tracks have artwork. Select some artwork for the program to use.
          * Once artwork and its image (if necessary) are selected, use the Repair menu.
          """, bundle: .module,
          comment:
            "Shown when application was granted access to MusicKit. Variable is the application name."
        )

    }
    return explanatoryText
  }

  private func handleButtonPressed() {
    switch musicAuthorizationStatus {
    case .notDetermined:
      Task { @MainActor in
        let musicAuthorizationStatus = await MusicAuthorization.request()
        update(with: musicAuthorizationStatus)
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
      buttonText = Text(
        "Continue", bundle: .module,
        comment:
          "Button Text in alert shown when MusicKit authorization status cannot be determined.")
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

  @Observable final class PresentationCoordinator {
    init() {
      let authorizationStatus = MusicAuthorization.currentStatus
      musicAuthorizationStatus = authorizationStatus
      isAuthorizationSheetPresented = (authorizationStatus != .authorized)
    }

    var musicAuthorizationStatus: MusicAuthorization.Status {
      didSet {
        isAuthorizationSheetPresented = (musicAuthorizationStatus != .authorized)
      }
    }

    var isAuthorizationSheetPresented: Bool
  }

  fileprivate struct SheetPresentationModifier: ViewModifier {
    @State private var presentationCoordinator = PresentationCoordinator()
    @Binding var isAuthorized: Bool

    func body(content: Content) -> some View {
      content
        .sheet(isPresented: $presentationCoordinator.isAuthorizationSheetPresented) {
          AuthorizationView(
            musicAuthorizationStatus: $presentationCoordinator.musicAuthorizationStatus
          )
          .interactiveDismissDisabled()
        }
        .onAppear {
          isAuthorized = presentationCoordinator.musicAuthorizationStatus == .authorized
        }
        .onChange(of: presentationCoordinator.musicAuthorizationStatus) { _, newValue in
          isAuthorized = (newValue == .authorized)
        }
    }
  }
}

extension View {
  @MainActor func musicKitAuthorizationSheet(isAuthorized: Binding<Bool>) -> some View {
    modifier(AuthorizationView.SheetPresentationModifier(isAuthorized: isAuthorized))
  }
}

#Preview {
  AuthorizationView(musicAuthorizationStatus: .constant(.authorized))
}
#Preview {
  AuthorizationView(musicAuthorizationStatus: .constant(.denied))
}
#Preview {
  AuthorizationView(musicAuthorizationStatus: .constant(.notDetermined))
}
#Preview {
  AuthorizationView(musicAuthorizationStatus: .constant(.restricted))
}
