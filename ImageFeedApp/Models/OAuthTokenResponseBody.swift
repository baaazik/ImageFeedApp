//
//  OAuthTokenResponseBody.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 28.07.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }

    let accessToken: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
    }
}

