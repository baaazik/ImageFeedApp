//
//  ProfilePresenter.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 03.08.2025.
//

import Foundation
import Kingfisher

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
    func doLogout()
}

class ProfileViewPresenter: ProfilePresenterProtocol {
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    private let logoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }

        if let profile = profileService.profile {
            view?.show(profile: profile)
        }

        updateAvatar()
    }

    func logout() {
        view?.showExitAlert()
    }

    func doLogout() {
        self.logoutService.logout()
        view?.switchToSplashController()
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        view?.show(avatar: nil)
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.view?.show(avatar: value.image)
            case .failure(let error):
                print("[ProfileViewPresenter] failed to load avatar image: \(error)")
            }
        }
    }
}
