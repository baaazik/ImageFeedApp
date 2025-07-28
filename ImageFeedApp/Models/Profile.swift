//
//  Profile.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 28.07.2025.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String

    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }

    init(from profileResult: ProfileResult) {
        username = profileResult.username
        name = "\(profileResult.firstName) \(profileResult.lastName ?? "")"
        loginName = "@\(profileResult.username)"
        bio = profileResult.bio ?? ""
    }
}
