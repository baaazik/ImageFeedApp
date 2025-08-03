//
//  ProfileViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 26.05.2025.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol? { get set }
    func show(profile: Profile)
    func show(avatar: UIImage?)
    func showExitAlert()
    func switchToSplashController()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    private let avatarImageViewSize = 70.0

    private lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage(resource: .photo)
        let avatarImageView = UIImageView()
        avatarImageView.image = avatarImage
        avatarImageView.layer.cornerRadius = avatarImageViewSize / 2
        avatarImageView.layer.masksToBounds = true
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
        exitButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }()

    var presenter: ProfilePresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        createElements()
        presenter?.viewDidLoad()
    }

    func show(profile: Profile) {
        nameText.text = profile.name
        accountText.text = profile.loginName
        statusText.text = profile.bio
    }

    func show(avatar: UIImage?) {
        if let avatar {
            avatarImageView.image = avatar
        } else {
            avatarImageView.image = UIImage(resource: .avatarPlaceholder)
        }
    }

    private func createElements() {
        view.addSubview(avatarImageView)
        view.addSubview(nameText)
        view.addSubview(accountText)
        view.addSubview(statusText)
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarImageViewSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarImageViewSize),

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

    @objc func logoutTapped() {
        presenter?.logout()
    }

    func showExitAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.doLogout()
        }

        let noAction = UIAlertAction(title: "Нет", style: .default)

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(alert, animated: true, completion: nil)
    }

    func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[ProfileLogoutService] invalid window configuration")
            return
        }

        window.rootViewController = SplashViewController()
    }
}
