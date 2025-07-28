//
//  UserResult.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 28.07.2025.
//

import Foundation

struct UserResult: Codable {
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }

    var profileImage: ProfileImage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profileImage = try container.decode(ProfileImage.self, forKey: .profileImage)
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
