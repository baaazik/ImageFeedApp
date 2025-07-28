//
//  ImagesListCellDelegate.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 24.07.2025.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
