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
    private var fetchTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared

    private let photosPerPage = 10

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    func fetchPhotosNextPage() {
        if let _ = fetchTask {
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
                            thumbImageURL: photoResult.urls.small,
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
            self.fetchTask = nil
        })

        self.fetchTask = task
        task.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if let _ = likeTask {
            return
        }

        guard
            let token = storage.token,
            let request = makeLikeRequest(token: token, isLike: isLike, id: photoId) else {
            assertionFailure("[ImageListService] Failed to create URLRequest")
            return
        }

        let task = URLSession.shared.data(for: request, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }

                completion(.success(()))
            case .failure(let error):
                print("[ImageListService] failed to like \(error)")
                completion(.failure(error))
            }
            self.likeTask = nil
        })

        self.likeTask = task
        task.resume()
    }

    private func makeImagesRequest(token: String, page: Int) -> URLRequest? {
        guard
            let baseURL = Constants.defaultBaseURL,
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

    private func makeLikeRequest(token: String, isLike: Bool, id: String) -> URLRequest? {
        guard
            let baseURL = Constants.defaultBaseURL,
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        components.path += "photos/\(id)/like"

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        if !isLike {
            request.httpMethod = HttpMethods.delete.rawValue
        }
        else {
            request.httpMethod = HttpMethods.post.rawValue
        }

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

private struct PhotoResult: Decodable {
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

private struct Urls: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
