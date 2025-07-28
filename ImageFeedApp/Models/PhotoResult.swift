//
//  PhotoResult.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 28.07.2025.
//

import Foundation


struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: Urls

    private static let dateFormatter = ISO8601DateFormatter()

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        let dateStr = try container.decode(String.self, forKey: .createdAt)
        createdAt = PhotoResult.dateFormatter.date(from: dateStr)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.likedByUser = try container.decode(Bool.self, forKey: .likedByUser)
        self.urls = try container.decode(Urls.self, forKey: .urls)
    }
}

struct Urls: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

