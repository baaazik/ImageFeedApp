//
//  AuthViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 11.06.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    @IBOutlet private weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // The only way I found to keep bold text after press
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        let title = NSAttributedString(string: "Войти", attributes: attributes)
        loginButton.setAttributedTitle(title, for: .normal)
        loginButton.setAttributedTitle(title, for: .highlighted)
        loginButton.setAttributedTitle(title, for: .selected)
    }

    @IBAction private func loginAction(_ sender: Any) {
    }
    
}
