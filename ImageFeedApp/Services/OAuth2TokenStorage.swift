//
//  OAuth2TokenStorage.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 21.06.2025.
//

import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case oauthToken
    }

    static let shared = OAuth2TokenStorage()
    private init() {}

    private let storage: UserDefaults = .standard

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.oauthToken.rawValue)
        }
        set {
            guard let newValue else {
                return
            }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: Keys.oauthToken.rawValue)
            if !isSuccess {
                print("[OAuth2TokenStorage] failed to save token")
            }
        }
    }

    func tokenDelete() {
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: Keys.oauthToken.rawValue)
        if !removeSuccessful {
            print("[OAuth2TokenStorage] failed to remove token")
        }
    }
}
