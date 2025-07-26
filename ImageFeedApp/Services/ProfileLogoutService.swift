//
//  ProfileLogoutService.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 27.07.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() { }

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let tokenStorage = OAuth2TokenStorage.shared

    func logout() {
        cleanCookies()
        tokenStorage.tokenDelete()
        profileService.clear()
        profileImageService.clear()
        switchToSplashController()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[ProfileLogoutService] invalid window configuration")
            return
        }

        window.rootViewController = SplashViewController()
    }
}

