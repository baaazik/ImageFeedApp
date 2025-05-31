//
//  SingleImageViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 27.05.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.contentInsetAdjustmentBehavior = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Call this in viewWillAppear, because in viewDidLoad scrollView.bounds.height has wrong
        // value and image is not centered
        if let image {
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        scrollView.layoutIfNeeded()

        let viewSize = scrollView.bounds
        let imageSize = image.size

        let scaleWidth = viewSize.width / imageSize.width
        let scaleHeight = viewSize.height / imageSize.height
        var scale = min(scaleWidth, scaleHeight)
        scale = min(max(scale, scrollView.minimumZoomScale), scrollView.maximumZoomScale)

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        centerImageInScrollView()
    }

    private func centerImageInScrollView() {
        let contentSize = scrollView.contentSize
        let viewSize = scrollView.bounds
        let x = (viewSize.width - contentSize.width) / 2
        let y = (viewSize.height - contentSize.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: 0, right: 0)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollView()
    }
}
