//
//  AuthViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 11.06.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    @IBOutlet private weak var loginButton: UIButton!
    private let segueId = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Load AuthViewController")

        // The only way I found to keep bold text after press
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        let title = NSAttributedString(string: "Войти", attributes: attributes)
        loginButton.setAttributedTitle(title, for: .normal)
        loginButton.setAttributedTitle(title, for: .highlighted)
        loginButton.setAttributedTitle(title, for: .selected)

        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            guard
                let destination = segue.destination as? WebViewViewController,
                let delegate = sender as? WebViewViewControllerDelegate
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            destination.delegate = delegate
        }
    }

    @IBAction private func loginAction(_ sender: Any) {
        performSegue(withIdentifier: segueId, sender: self)
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("User logged in, get token")

        oauth2Service.fetchOAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                let storage = OAuth2TokenStorage()
                print("Successfully got token")
                storage.token = token
                delegate?.didAuthenticate(self)
            case .failure(let error):
                print("Error: failed to get OAuth 2 token: \(error)")
                navigationController?.popToViewController(self, animated: true)
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }

}
