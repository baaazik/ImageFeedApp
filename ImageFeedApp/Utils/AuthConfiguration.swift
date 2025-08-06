//
//  Constants.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 09.06.2025.
//

import Foundation

enum Constants {
    static let accessKey = "h7X7c_w4d5LtLtaIMNXyaFnOMQH8u2cxPyC_tOB2Q8c"
    static let secretKey = "u0N2iyWMteTDx04z8H_a6BGBSDG1MH8OPpl_0Gp3pRM"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL?
    let authURLString: String

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            authURLString: Constants.unsplashAuthorizeURLString)
    }
}
