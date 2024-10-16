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
    @State private var accessToken = ""

    var body: some View {
        VStack {
            if accessToken.isEmpty {
                Button("Sign in") {
                    Task {
                        do {
                            let parameters = OAuth2PKCEParameters(
                                authorizationEndpoint: "https://accounts.google.com/o/oauth2/v2/auth",
                                tokenEndpoint: "https://oauth2.googleapis.com/token",
                                clientId: "536177625423-pgg73j72t5rm2cotakfn6erj8979ioep.apps.googleusercontent.com",
                                redirectUri: "com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep:/oauth2redirect/example-provider",
                                callbackURLScheme: "com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep"
                            )
                            // Perform the authentication and await the result.
                            let response = try await OAuth2PKCEAuthenticator().authenticate(
                                parameters: parameters,
                                webAuthenticationSession: webAuthenticationSession
                            )
                            accessToken = String(describing: response)
                        } catch {
                            // Respond to any authorization errors.
                            print(error)
                        }
                    }
                }
            } else {
                Text(accessToken)
            }
        }
    }
}

#Preview {
    ContentView()
}
