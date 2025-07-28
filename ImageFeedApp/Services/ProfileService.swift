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
                let profile = Profile(from: response)
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
