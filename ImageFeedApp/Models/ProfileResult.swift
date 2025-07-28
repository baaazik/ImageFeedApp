//
//  ProfileResult.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 28.07.2025.
//

import Foundation

struct ProfileResult: Decodable {
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }

    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decode(String.self, forKey: .username)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String?.self, forKey: .lastName)
        self.bio = try container.decode(String?.self, forKey: .bio)
    }

}
