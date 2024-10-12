//
//  OAuth2PKCEAuthenticator.swift
//  WebAuthentication-iOS
//
//  Created by Stephano Hugues TELOLAHY on 12/10/2024.
//

import SwiftUI
import AuthenticationServices
import CommonCrypto
import Foundation

public struct OAuth2PKCEParameters {
    public var authorizationEndpoint: String
    public var tokenEndpoint: String
    public var clientId: String
    public var redirectUri: String
    public var callbackURLScheme: String
}

public enum OAuth2PKCEAuthenticatorError: LocalizedError {
    case authRequestFailed(Error)
    case authorizeResponseNoUrl
    case authorizeResponseNoCode
    case tokenRequestFailed(Error)
    case tokenResponseNoData
    case tokenResponseInvalidData(String)

    var localizedDescription: String {
        switch self {
        case .authRequestFailed(let error):
            return "authorization request failed: \(error.localizedDescription)"
        case .authorizeResponseNoUrl:
            return "authorization response does not include a url"
        case .authorizeResponseNoCode:
            return "authorization response does not include a code"
        case .tokenRequestFailed(let error):
            return "token request failed: \(error.localizedDescription)"
        case .tokenResponseNoData:
            return "no data received as part of token response"
        case .tokenResponseInvalidData(let reason):
            return "invalid data received as part of token response: \(reason)"
        }
    }
}

public struct AccessTokenResponse: Codable {
    public var access_token: String
    public var expires_in: Int
}

public struct OAuth2PKCEAuthenticator {

    public func authenticate(
        parameters: OAuth2PKCEParameters,
        webAuthenticationSession: WebAuthenticationSession
    ) async throws -> AccessTokenResponse {
        // 1. creates a cryptographically-random code_verifier
        let codeVerifier = createCodeVerifier()
        // 2. and from this generates a code_challenge
        let codeChallenge = codeChallenge(for: codeVerifier)
        // 3. redirects the user to the authorization server along with the code_challenge

        let authUrl = "\(parameters.authorizationEndpoint)?response_type=code&scope=openid%20profile&code_challenge=\(codeChallenge)&code_challenge_method=S256&client_id=\(parameters.clientId)&redirect_uri=\(parameters.redirectUri)"

        let responseUrl = try await webAuthenticationSession.authenticate(
            using: URL(string: authUrl)!,
            callbackURLScheme: parameters.callbackURLScheme,
            preferredBrowserSession: .ephemeral
        )

        // authorization server stores the code_challenge and redirects the user back to the application with an authorization code, which is good for one use
        guard let code = responseUrl.getQueryStringParameter(
            "code"
        ) else { throw OAuth2PKCEAuthenticatorError.authorizeResponseNoCode
        }

        // 4. sends this code and the code_verifier (created in step 2) to the authorization server (token endpoint)
        let accessTokenResponse = try await getAccessToken(
            authCode: code,
            codeVerifier: codeVerifier,
            parameters: parameters
        )

        return accessTokenResponse
    }
}

private extension OAuth2PKCEAuthenticator {
    func createCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(bytes: buffer)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    func codeChallenge(for verifier: String) -> String {
        // Dependency: Apple Common Crypto library
        // http://opensource.apple.com//source/CommonCrypto
        guard let data = verifier.data(using: .utf8) else { fatalError() }
        var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
        }
        let hash = Data(bytes: buffer)
        return hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    func getAccessToken(
        authCode: String,
        codeVerifier: String,
        parameters: OAuth2PKCEParameters
    ) async throws -> AccessTokenResponse {
        let request = URLRequest.createTokenRequest(
            parameters: parameters,
            code: authCode,
            codeVerifier: codeVerifier)
        let (data, response) = try await URLSession.shared.data(for: request)
        let tokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
        return tokenResponse
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}

private extension URL {
    func getQueryStringParameter(_ parameter: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == parameter })?.value
    }
}

private extension URLRequest {
    static func createTokenRequest(parameters: OAuth2PKCEParameters, code: String, codeVerifier: String) -> URLRequest {
        let request = NSMutableURLRequest(
            url: NSURL(string: "\(parameters.tokenEndpoint)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded"]
        request.httpBody = NSMutableData(
            data: "grant_type=authorization_code&client_id=\(parameters.clientId)&code_verifier=\(codeVerifier)&code=\(code)&redirect_uri=\(parameters.redirectUri)"
                .data(using: String.Encoding.utf8)!
        ) as Data
        return request as URLRequest
    }
}
