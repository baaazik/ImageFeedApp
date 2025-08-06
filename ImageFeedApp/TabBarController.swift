//
//  TabBarController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 08.07.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListService = ImagesListService()
        let imageListPresenter = ImagesListViewPresenter(imageListService: imagesListService)

        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard var imagesListViewController = viewController as? ImagesListViewControllerProtocol else {
            return
        }

        imageListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imageListPresenter

        let imageLoader = KingFisherImageLoader()
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let logoutService = ProfileLogoutService.shared

        let profilePresenter = ProfileViewPresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            logoutService: logoutService,
            imageLoader: imageLoader)
        
        let profileViewController = ProfileViewController()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [viewController, profileViewController]
    }
}
