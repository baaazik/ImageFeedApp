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
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
    }

    @IBAction private func loginAction(_ sender: Any) {
    }
    
}
