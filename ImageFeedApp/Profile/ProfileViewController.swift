//
//  ProfileViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 26.05.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
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
        nameText.text = ""
        nameText.textColor = .ypWhite
        nameText.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        nameText.translatesAutoresizingMaskIntoConstraints = false
        return nameText
    }()

    private lazy var accountText: UILabel! = {
        let accountText = UILabel()
        accountText.text = ""
        accountText.textColor = .ypGray
        accountText.font = UIFont.systemFont(ofSize: 13)
        accountText.translatesAutoresizingMaskIntoConstraints = false
        return accountText
    }()

    private lazy var statusText: UILabel! = {
        let statusText = UILabel()
        statusText.text = ""
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

    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    private let logoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayers: [CALayer] = []
    private var isLoaded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        createElements()

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateProfile()
            }
        updateProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isLoaded {
            showPlaceholderAnimation()
        }
    }

    private func updateProfile() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .avatarPlaceholder)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.isLoaded = true
                        self.nameText.text = self.profileService.profile?.name
                        self.accountText.text = self.profileService.profile?.loginName
                        self.statusText.text = self.profileService.profile?.bio
                        self.hidePlaceholderAnimation()
                    }
                case .failure(let error):
                    print("[ProfileViewController] failed to load profile image: \(error)")
                }
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
            nameText.heightAnchor.constraint(equalToConstant: 18),

            accountText.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 8),
            accountText.leadingAnchor.constraint(equalTo: nameText.leadingAnchor),
            accountText.heightAnchor.constraint(equalToConstant: 18),

            statusText.topAnchor.constraint(equalTo: accountText.bottomAnchor, constant: 8),
            statusText.leadingAnchor.constraint(equalTo: accountText.leadingAnchor),
            statusText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            accountText.heightAnchor.constraint(equalToConstant: 18),

            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func showPlaceholderAnimation() {
        let avatarGradient = CreateGradient(size: CGSize(width: avatarImageViewSize, height: avatarImageViewSize), cornerRadius: avatarImageViewSize / 2)
        avatarImageView.layer.addSublayer(avatarGradient)

        let nameGradient = CreateGradient(size: CGSize(width: 223, height: 18), cornerRadius: 9)
        nameText.layer.addSublayer(nameGradient)

        let accountGradient = CreateGradient(size: CGSize(width: 89, height: 18), cornerRadius: 9)
        accountText.layer.addSublayer(accountGradient)

        let statusGradient = CreateGradient(size: CGSize(width: 57, height: 18), cornerRadius: 9)
        statusText.layer.addSublayer(statusGradient)

        animationLayers.append(contentsOf: [avatarGradient, nameGradient, accountGradient, statusGradient])
    }

    private func hidePlaceholderAnimation() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
    }

    private func increaseSize(size: CGSize, padding: CGFloat) -> CGSize {
        return CGSize(width: size.width, height: size.height + padding * 2)
    }

    @objc func logoutTapped() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.logoutService.logout()
            self.switchToSplashController()
        }

        let noAction = UIAlertAction(title: "Нет", style: .default)

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(alert, animated: true, completion: nil)
    }

    private func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[ProfileLogoutService] invalid window configuration")
            return
        }

        window.rootViewController = SplashViewController()
    }
}
