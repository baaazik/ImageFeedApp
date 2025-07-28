//
//  Photo.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 28.07.2025.
//

import Foundation


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool

    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }

    init(from photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        createdAt = photoResult.createdAt
        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.small
        largeImageURL = photoResult.urls.full
        isLiked = photoResult.likedByUser
    }
}

