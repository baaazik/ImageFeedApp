//
//  OAuth2TokenStorage.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 21.06.2025.
//

import UIKit

final class OAuth2TokenStorage {
    private enum Keys: String {
        case oauthToken
    }

    static let shared = OAuth2TokenStorage()
    private init() {}

    private let storage: UserDefaults = .standard

    var token: String? {
        get {
            storage.string(forKey: Keys.oauthToken.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.oauthToken.rawValue)
        }
    }

    func tokenDelete() {
        storage.removeObject(forKey: Keys.oauthToken.rawValue)
    }
}
