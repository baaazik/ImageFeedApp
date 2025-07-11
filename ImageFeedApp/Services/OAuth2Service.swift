//
//  OAuth2Service.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 19.06.2025.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            assertionFailure("Failed to create URLRequest")
            return
        }

        let task = URLSession.shared.data(for: request, completion: {result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(response.accessToken))
                }
                catch {
                    print("Error: failed to deserialize JSON \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Error: failed to make a request: \(error)")
                completion(.failure(error))
            }
        })
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.post.rawValue

        return request
    }
}

private struct OAuthTokenResponseBody: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }

    var accessToken: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
    }
}

private enum HttpMethods: String {
    case get = "GET"
    case post = "POST"
}
