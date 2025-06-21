//
//  WebViewViewControllerDelegate.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 16.06.2025.
//

import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController,
                               didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
