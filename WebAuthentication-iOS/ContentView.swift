//
//  ContentView.swift
//  WebAuthentication-iOS
//
//  Created by Stephano Hugues TELOLAHY on 11/10/2024.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State private var accessToken: String?
    @State private var occurredError: OAuthError?
    @State var showSafari = false

    var body: some View {
        VStack(spacing: 20) {

            Button("Sign in with WebAuthenticationSession") {
                Task {
                    do {
                        let response = try await OAuth2PKCEAuthenticator().authenticate(
                            parameters: .googleOAuthParameters,
                            webAuthenticationSession: webAuthenticationSession
                        )
                        accessToken = String(describing: response)
                    } catch {
                        occurredError = .init(underlying: error)
                    }
                }
            }

            Button("Sign in with Safari") {
                showSafari.toggle()
            }

            if let accessToken {
                Text("Authenticated: \(accessToken)")
            }

        }
        .alert(item: $occurredError) { error in
            Alert(
                title: Text("Error"),
                message: Text(String(describing: error.underlying)),
                dismissButton: .cancel()
            )
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: "https://accounts.google.com")!)
        }
    }
}

#Preview {
    ContentView()
}

private extension OAuth2PKCEParameters {
    static var googleOAuthParameters: Self {
        .init(
            authorizationEndpoint: "https://accounts.google.com/o/oauth2/v2/auth",
            tokenEndpoint: "https://oauth2.googleapis.com/token",
            clientId: "536177625423-pgg73j72t5rm2cotakfn6erj8979ioep.apps.googleusercontent.com",
            redirectUri: "com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep:/oauth2redirect/example-provider",
            callbackURLScheme: "com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep",
            additionalHeaders: [
                "locale": "fr",
                "apiKey": "AIzaSyDaGmWKa4JsXZ-HjGw7ISLn_3namBGewQe"
            ]
        )
    }

    static var localhostOAuthParameters: Self {
        .init(
            authorizationEndpoint: "http://localhost:8888/index.html",
            tokenEndpoint: "http://localhost:8888/token",
            clientId: "1",
            redirectUri: "myapp://oauth2redirect",
            callbackURLScheme: "myapp",
            additionalHeaders: [:]
        )
    }
}

struct OAuthError: Identifiable {
    var id: String = UUID().uuidString
    let underlying: Error
}
