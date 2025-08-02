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
    private let storage = OAuth2TokenStorage.shared
    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[AuthViewController] load")

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
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let presenter = WebViewPresenter()
            webViewViewController.presenter = presenter
            webViewViewController.delegate = self
            presenter.view = webViewViewController
        }
    }

    @IBAction private func loginAction(_ sender: Any) {
        performSegue(withIdentifier: segueId, sender: self)
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("[AuthViewController] user logged in, get token")

        navigationController?.popToViewController(self, animated: true)
        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                print("[AuthViewController] Successfully got token")
                storage.token = token
                delegate?.didAuthenticate(self)
            case .failure(let error):
                print("[AuthViewController] failed to get OAuth 2 token: \(error)")
                showErrorAlert(on: self, title: "Что-то пошло не так", message: "Не удалось войти в систему")
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }

}
