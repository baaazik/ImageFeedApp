//
//  WebViewViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 15.06.2025.
//

import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }

    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {

    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var webView: WKWebView!
    weak var delegate: WebViewViewControllerDelegate?
    private var observer: NSKeyValueObservation?

    var presenter: WebViewPresenterProtocol? 

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[WebViewViewController] load")

        webView.navigationDelegate = self
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        observer = webView.observe(
                \.estimatedProgress,
                 options: [.new]
            ) { [weak self] webView, change in
                guard let self = self else { return }
                self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
            }
    }

    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = Float(newValue)
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if
            let url = navigationAction.request.url,
            let code = presenter?.code(from: url) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
