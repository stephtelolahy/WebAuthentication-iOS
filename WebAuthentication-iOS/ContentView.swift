//
//  ContentView.swift
//  WebAuthentication-iOS
//
//  Created by Stephano Hugues TELOLAHY on 11/10/2024.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    // Get an instance of WebAuthenticationSession using SwiftUI's
    // @Environment property wrapper.
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    var body: some View {
        Button("Sign in") {
            Task {
                do {
                    // Perform the authentication and await the result.
                    // https://developers.google.com/identity/protocols/oauth2/native-app#ios_1
                    let authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
                    let clientId = "536177625423-etu4d72tjl4ej68qgpc6k02mfe97vlvi.apps.googleusercontent.com"
                    let redirectScheme = "com.googleusercontent.apps.536177625423-etu4d72tjl4ej68qgpc6k02mfe97vlvi"
                    let redirectUri = "com.googleusercontent.apps.536177625423-etu4d72tjl4ej68qgpc6k02mfe97vlvi"
                    let authorizationScope = "profile"
                    let authURL = "\(authorizationEndpoint)?scope=\(authorizationScope)&response_type=code&client_id=\(clientId)&redirect_uri=\(redirectUri)"

                    let urlWithToken = try await webAuthenticationSession.authenticate(
                        using: URL(string: authURL)!,
                        callbackURLScheme: redirectScheme,
                        preferredBrowserSession: .ephemeral
                    )
                    // Call the method that completes the authentication using the
                    // returned URL.
                    try await signIn(using: urlWithToken)
                } catch {
                    // Respond to any authorization errors.
                }
            }
        }
    }

    private func signIn(using urlWithToken: URL) async throws {
//        let queryItems = URLComponents(string: urlWithToken.absoluteString)?.queryItems
//        let token = queryItems?.filter({ $0.name == "token" }).first?.value
        print(urlWithToken)
    }
}

#Preview {
    ContentView()
}
