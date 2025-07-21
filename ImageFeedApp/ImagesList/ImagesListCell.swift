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
    
    static let reuseIdentifier = "ImagesListCell"

    override func prepareForReuse() {
           super.prepareForReuse()
            photoImageView.kf.cancelDownloadTask()
       }
}
