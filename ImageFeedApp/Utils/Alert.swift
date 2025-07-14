//
//  Alert.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 30.06.2025.
//

import UIKit

func showErrorAlert(on viewController: UIViewController, title: String, message: String) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
    )

    let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
    alert.addAction(okAction)

    viewController.present(alert, animated: true, completion: nil)
}

