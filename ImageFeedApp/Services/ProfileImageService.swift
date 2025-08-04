//
//  ProfileImageService.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 30.06.2025.
//

import UIKit

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService()
    private init() {}

    private let storage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?

    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {

        if let _ = task {
            print("[ProfileImageService] request is already in progress")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        guard
            let token = storage.token,
            let request = makeProfileRequest(token: token, username: username) else {
            assertionFailure("[ProfileImageService] Failed to create URLRequest")
            return
        }

        let task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let response):
                let image = response.profileImage.small
                completion(.success(image))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": image])
            case .failure(let error):
                print("[ProfileImageService] failed to make a request: \(error)")
                completion(.failure(error))
            }
            self?.task = nil
        })
        self.task = task
        task.resume()
    }

    func clear() {
        avatarURL = nil
    }

    private func makeProfileRequest(token: String, username: String) -> URLRequest? {
        guard
            let baseURL = Constants.defaultBaseURL,
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        components.path += "users/\(username)"

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func updateProfileImage(avatarURL: String) {
        self.avatarURL = avatarURL
    }

}
