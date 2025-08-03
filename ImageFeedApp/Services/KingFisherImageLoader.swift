//
//  KingFisherImageLoader.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 03.08.2025.
//

import UIKit
import Kingfisher

class KingFisherImageLoader: ImageLoader {
    func loadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                completion(.success(value.image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    

}
