//
//  ProfileViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 26.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    private lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage(resource: .photo)
        let avatarImageView = UIImageView()
        avatarImageView.image = avatarImage
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    private lazy var nameText: UILabel! = {
        let nameText = UILabel()
        nameText.text = "Екатерина Новикова"
        nameText.textColor = .ypWhite
        nameText.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        nameText.translatesAutoresizingMaskIntoConstraints = false
        return nameText
    }()

    private lazy var accountText: UILabel! = {
        let accountText = UILabel()
        accountText.text = "@ekaterina_nov"
        accountText.textColor = .ypGray
        accountText.font = UIFont.systemFont(ofSize: 13)
        accountText.translatesAutoresizingMaskIntoConstraints = false
        return accountText
    }()

    private lazy var statusText: UILabel! = {
        let statusText = UILabel()
        statusText.text = "Hello, world!"
        statusText.textColor = .ypWhite
        statusText.font = UIFont.systemFont(ofSize: 13)
        statusText.translatesAutoresizingMaskIntoConstraints = false
        statusText.numberOfLines = 0
        statusText.lineBreakMode = .byWordWrapping
        return statusText
    }()

    private lazy var exitButton: UIButton! = {
        let buttonImage = UIImage(resource: .exit)
        let exitButton = UIButton()
        exitButton.setImage(buttonImage, for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }()

    private let profileService = ProfileService()
    private let storage = OAuth2TokenStorage.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        createElements()

        guard let token = storage.token else {
            return
        }
        profileService.fetchProfile(token, completion: { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let profile):
                self.nameText.text = profile.name
                self.accountText.text = profile.loginName
                self.statusText.text = profile.bio
            case .failure(let error):
                print("Error: failed to load profile \(error)")
            }
        })
    }

    func createElements() {
        view.addSubview(avatarImageView)
        view.addSubview(nameText)
        view.addSubview(accountText)
        view.addSubview(statusText)
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameText.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameText.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),

            accountText.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 8),
            accountText.leadingAnchor.constraint(equalTo: nameText.leadingAnchor),

            statusText.topAnchor.constraint(equalTo: accountText.bottomAnchor, constant: 8),
            statusText.leadingAnchor.constraint(equalTo: accountText.leadingAnchor),
            statusText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
