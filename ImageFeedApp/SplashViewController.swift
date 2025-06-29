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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Load SplashViewController")

        if let token = storage.token {
            // Don't call fetchProfile from viewDidAppear, because there will
            // be a two calls of fetchProfile from viewDidAppear and from didAuthenticate.
            // Therefore, second call fails and error message appears
            print("Token exists")
            fetchProfile(token)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")

        guard let _ = storage.token else {
            print("No saved token, launch auth view")
            performSegue(withIdentifier: segueId, sender: self)
            return
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            guard
                let navigation = segue.destination as? UINavigationController,
                let auth = navigation.viewControllers[0] as? AuthViewController,
                let delegate = sender as? AuthViewControllerDelegate
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            auth.delegate = delegate
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
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
                profileService.updateProfileDetails(profile: profile)
                self.switchToTabBarController()
            case .failure:
                showErrorAlert(on: self, message: "Не удалось загрузить профиль")
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("User successfully authenticated")
        vc.dismiss(animated: true)

        guard let token = storage.token else {
            return
        }
        fetchProfile(token)
    }
}
