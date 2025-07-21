//
//  ImagesListService.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 16.07.2025.
//

import UIKit

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared

    private let photosPerPage = 10

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    func fetchPhotosNextPage() {
        if let _ = task {
            return
        }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard
            let token = storage.token,
            let request = makeImagesRequest(token: token, page: nextPage) else {
            assertionFailure("[ImageListService] Failed to create URLRequest")
            return
        }

        let task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<[PhotoResult], Error>) in

            guard let self = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    for photoResult in response {
                        let photo = Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: photoResult.createdAt,
                            welcomeDescription: photoResult.description,
                            thumbImageURL: photoResult.urls.thumb,
                            largeImageURL: photoResult.urls.full,
                            isLiked: photoResult.likedByUser
                        )
                        self.photos.append(photo)
                    }

                    self.lastLoadedPage = nextPage

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: nil,
                        userInfo: ["photos": self.photos]
                    )
                }
            case .failure(let error):
                print("[ImageListService] failed to make a request: \(error)")
            }
            self.task = nil
        })

        self.task = task
        task.resume()
    }

    private func makeImagesRequest(token: String, page: Int) -> URLRequest? {
        guard
            let baseURL = Constants.fakeBaseURL,
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        components.path += "photos"

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(photosPerPage))
        ]


        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: Urls

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
        if let createdAt = ISO8601DateFormatter().date(from: dateStr) {
            self.createdAt = createdAt
        } else {
            self.createdAt = Date()
        }
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.likedByUser = try container.decode(Bool.self, forKey: .likedByUser)
        self.urls = try container.decode(Urls.self, forKey: .urls)
    }
}

struct Urls: Decodable {
    let thumb: String
    let full: String
}
