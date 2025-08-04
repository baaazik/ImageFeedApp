//
//  ProfilePresenter.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 03.08.2025.
//

import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
    func doLogout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private let imageLoader: ImageLoader

    private var profileImageServiceObserver: NSObjectProtocol?

    var view: ProfileViewControllerProtocol?

    init(profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol,
         logoutService: ProfileLogoutServiceProtocol,
         imageLoader: ImageLoader) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
        self.imageLoader = imageLoader
    }

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
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        view?.show(avatar: nil)
        imageLoader.loadImage(url: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.view?.show(avatar: image)
            case .failure(let error):
                print("[ProfileViewPresenter] failed to load avatar image: \(error)")
            }
        }
    }
}
