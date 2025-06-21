//
//  SplashViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 21.06.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let segueId = "ShowAuthView"
    private let storage = OAuth2TokenStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Load SplashViewController")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let _ = storage.token {
            print("Token exists")
            switchToTabBarController()
        }
        else {
            print("No saved token, launch auth view")
            performSegue(withIdentifier: segueId, sender: self)
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
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("User successfully authenticated")
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}
