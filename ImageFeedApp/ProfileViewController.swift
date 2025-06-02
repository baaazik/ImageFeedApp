//
//  ProfileViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 26.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    var avatarImageView: UIImageView!
    var nameText: UILabel!
    var accountText: UILabel!
    var statusText: UILabel!
    var exitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        createElements()
    }

    func createElements() {
        let avatarImage = UIImage(named: "Photo")
        avatarImageView = UIImageView()
        avatarImageView.image = avatarImage
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)

        nameText = UILabel()
        nameText.text = "Екатерина Новикова"
        nameText.textColor = .ypWhite
        nameText.font = UIFont.boldSystemFont(ofSize: 23)
        nameText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameText)

        accountText = UILabel()
        accountText.text = "@ekaterina_nov"
        accountText.textColor = .ypGray
        accountText.font = UIFont(name: "SF Pro", size: 13)
        accountText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(accountText)

        statusText = UILabel()
        statusText.text = "Hello, world!"
        statusText.textColor = .ypWhite
        statusText.font = UIFont(name: "SF Pro", size: 13)
        statusText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusText)

        let buttonImage = UIImage(named: "Exit")
        exitButton = UIButton()
        exitButton.setImage(buttonImage, for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameText.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameText.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),

            accountText.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 8),
            accountText.leadingAnchor.constraint(equalTo: nameText.leadingAnchor),

            statusText.topAnchor.constraint(equalTo: accountText.bottomAnchor, constant: 8),
            statusText.leadingAnchor.constraint(equalTo: accountText.leadingAnchor),

            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

}
