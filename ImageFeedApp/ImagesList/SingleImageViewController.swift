//
//  SingleImageViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 27.05.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?

    private var isScaled: Bool = false

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.contentInsetAdjustmentBehavior = .never

        if let image {
            imageView.image = image
            imageView.frame.size = image.size
            //rescaleImageInScrollView(image: image)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Call this in viewWillAppear, because in viewDidLoad scrollView.bounds.height has wrong
        // value and image is not centered
        if let image {
            if !isScaled {
                // Calculate and set scale once, because viewWillAppear can be called multiple
                // times causing instant scale change
                rescaleImageInScrollView(image: image)
                isScaled = true
            }
            centerImageInScrollView()
        }
    }

    @IBAction private func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func shareAction(_ sender: Any) {
        guard let image else {
            return
        }
        let activityItems: [Any] = [image]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        self.present(activityViewController, animated: true, completion: nil)
    }

    private func rescaleImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        scrollView.layoutIfNeeded()

        let viewSize = scrollView.bounds
        let imageSize = image.size

        let scaleWidth = viewSize.width / imageSize.width
        let scaleHeight = viewSize.height / imageSize.height
        var scale = max(scaleWidth, scaleHeight)
        scale = min(max(scale, scrollView.minimumZoomScale), scrollView.maximumZoomScale)

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        // Set initial image position
        // Offset should be positive
        var (x, y) = calculateCentralPosition()
        x = max(-x, 0)
        y = min(-y, 0)
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }

    private func calculateCentralPosition() -> (Double, Double) {
        let contentSize = scrollView.contentSize
        let viewSize = scrollView.bounds
        let x = (viewSize.width - contentSize.width) / 2
        let y = (viewSize.height - contentSize.height) / 2

        return (x, y)
    }

    private func centerImageInScrollView() {
        var (x, y) = calculateCentralPosition()
        x = max(x, 0)
        y = max(y, 0)
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: 0, right: 0)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollView()
    }
}
