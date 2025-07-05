//
//  ProfileImageService.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 30.06.2025.
//

import UIKit

final class ProfileImageService {
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

private struct UserResult: Codable {
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }

    var profileImage: ProfileImage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profileImage = try container.decode(ProfileImage.self, forKey: .profileImage)
    }
}

private struct ProfileImage: Codable {
    var small: String
    var medium: String
    var large: String
}
