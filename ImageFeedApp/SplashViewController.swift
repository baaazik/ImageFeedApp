//
//  SplashViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 21.06.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let segueId = "ShowAuthView"
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private lazy var logo: UIImageView = {
        let logoImage = UIImage(resource: .splashScreen)
        let logoImageView = UIImageView()
        logoImageView.image = logoImage
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView

    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[SplashViewController] load")
        createElements()

        if let token = storage.token {
            // Don't call fetchProfile from viewDidAppear, because there will
            // be a two calls of fetchProfile from viewDidAppear and from didAuthenticate.
            // Therefore, second call fails and error message appears
            print("[SplashViewController] token exists")
            fetchProfile(token)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let _ = storage.token else {
            print("[SplashViewController] no saved token, launch auth view")
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            guard let viewController = viewController as? AuthViewController else {
                return
            }
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
            return
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[SplashViewController] invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                print("[SplashViewController] loaded profile")
                self.profileService.updateProfileDetails(profile: profile)

                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
                    switch result {
                    case .success(let imageURL):
                        print("[SplashViewController] loaded profile image")
                        ProfileImageService.shared.updateProfileImage(avatarURL: imageURL)
                    case .failure(let error):
                        print("[SplashViewController] failed to load profile image URL \(error)")
                    }
                }

                self.switchToTabBarController()
            case .failure(let error):
                print("[SplashViewController] failed to load profile: \(error)")
                showErrorAlert(on: self, title: "Что-то пошло не так", message: "Не удалось загрузить профиль")
            }
        }
    }

    private func createElements() {
        view.addSubview(logo)
        view.backgroundColor = .ypBlack

        NSLayoutConstraint.activate([
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 75),
            logo.heightAnchor.constraint(equalToConstant: 78),
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("[SplashViewController] user successfully authenticated")
        vc.dismiss(animated: true)

        guard let token = storage.token else {
            return
        }
        fetchProfile(token)
    }
}
