//
//  ProfileService.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 27.06.2025.
//

import UIKit

enum ProfileServiceError: Error {
    case invalidRequest
}
final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private var task: URLSessionTask?
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let _ = task {
            print("[ProfileService] request is already in progress")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        guard let request = makeProfileRequest(token: token) else {
            assertionFailure("[ProfileService] Failed to create URLRequest")
            return
        }

        let task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let response):
                let profile = Profile(username: response.username, name: "\(response.firstName) \(response.lastName ?? "")", loginName: "@\(response.username)", bio: response.bio ?? "")
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService] failed to make a request: \(error)")
                completion(.failure(error))
            }
            self?.task = nil
        })

        self.task = task
        task.resume()
    }

    func clear() {
        profile = nil
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard
            let baseURL = Constants.defaultBaseURL,
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        components.path += "me"

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func updateProfileDetails(profile: Profile) {
        self.profile = profile
    }
}

private struct ProfileResult: Decodable {
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }

    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decode(String.self, forKey: .username)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String?.self, forKey: .lastName)
        self.bio = try container.decode(String?.self, forKey: .bio)
    }

}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}
