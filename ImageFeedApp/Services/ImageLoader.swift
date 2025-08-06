//
//  ImageLoader.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 03.08.2025.
//

import UIKit

protocol ImageLoader {
    func loadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}
