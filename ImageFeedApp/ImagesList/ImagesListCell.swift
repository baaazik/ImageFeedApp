//
//  ImagesListCell.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 23.05.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateText: UILabel!
    weak var delegate: ImagesListCellDelegate?

    static let reuseIdentifier = "ImagesListCell"

    override func prepareForReuse() {
           super.prepareForReuse()
            photoImageView.kf.cancelDownloadTask()
       }

    @IBAction private func likeButtonAction(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }

    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? ImageResource.activeLike : ImageResource.like
        likeButton.setImage(UIImage(resource: likeImage), for: .normal)

    }
}
