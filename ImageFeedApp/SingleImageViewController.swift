//
//  SingleImageViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 27.05.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
