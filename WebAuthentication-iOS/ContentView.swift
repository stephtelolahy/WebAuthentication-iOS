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
                    let clientId = "536177625423-pgg73j72t5rm2cotakfn6erj8979ioep.apps.googleusercontent.com"
                    let redirectUri = "com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep:/oauth2redirect/example-provider"
                    let redirectScheme = "com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep"
//                    let authorizationScope = "profile"
//                    let authURL = "\(authorizationEndpoint)?scope=\(authorizationScope)&response_type=code&client_id=\(clientId)&redirect_uri=\(redirectUri)"

                    let authURL = "https://accounts.google.com/o/oauth2/v2/auth?nonce=IQDZxN4apkEfYvFHJgr1adQk_mBvaNdGeO6-BEu0Pq8&response_type=code&code_challenge_method=S256&scope=openid%20profile&code_challenge=C-OkbjRy5T5Ox1hnz1uxZDGCIx98BYgfDlrss1nv_1M&redirect_uri=com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep:/oauth2redirect/example-provider&client_id=536177625423-pgg73j72t5rm2cotakfn6erj8979ioep.apps.googleusercontent.com&state=p6Rx3sr38B7adJI4cncVtTbpsLpSD7rhTU3aHjfTgdY"

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
        // com.googleusercontent.apps.536177625423-pgg73j72t5rm2cotakfn6erj8979ioep:/oauth2redirect/example-provider?state=p6Rx3sr38B7adJI4cncVtTbpsLpSD7rhTU3aHjfTgdY&code=4/0AVG7fiRrYPPhsFSTDgJQItf0j0pvKXOZrH9cWCligmd2BoEDgA8XEzPFLRbXgl4Ei7EUHw&scope=profile%20openid%20https://www.googleapis.com/auth/userinfo.profile&authuser=0&prompt=consent
    }
}

#Preview {
    ContentView()
}
