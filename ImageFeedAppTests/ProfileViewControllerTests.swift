//
//  ProfileViewControllerTests.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 04.08.2025.
//

@testable import ImageFeedApp
import XCTest

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var expectation: XCTestExpectation?
    var avatarShown: UIImage?
    var profileShown: Profile?
    var showAlertCalled = false
    var switchCalled = false

    init(expectation: XCTestExpectation?) {
        self.expectation = expectation
    }

    func show(profile: ImageFeedApp.Profile) {
        self.profileShown = profile
    }
    
    func show(avatar: UIImage?) {
        if avatar != nil && self.avatarShown == nil{
            self.avatarShown = avatar
            expectation?.fulfill()
        }
    }
    
    func showExitAlert() {
        showAlertCalled = true
    }
    
    func switchToSplashController() {
        switchCalled = true
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logout() {

    }
    
    func doLogout() {

    }

}

final class ImageLoaderStub: ImageLoader {
    var urlRequested: URL?
    var image: UIImage?

    init(image: UIImage?) {
        self.image = image
    }

    func loadImage(url: URL, completion: @escaping (Result<UIImage, any Error>) -> Void) {
        urlRequested = url
        if let image {
            completion(.success(image))
        }
    }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: ImageFeedApp.Profile?

    init(profile: Profile?) {
        self.profile = profile
    }

    func fetchProfile(_ token: String, completion: @escaping (Result<ImageFeedApp.Profile, any Error>) -> Void) {
    }
}

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?

    init(avatarURL: String?) {
        self.avatarURL = avatarURL
    }

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, any Error>) -> Void) {
        NotificationCenter.default
            .post(
                name: ProfileImageService.didChangeNotification,
                object: nil,
                userInfo: ["URL": self.avatarURL ?? ""])
    }
}

final class LogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled = false
    func logout() {
        logoutCalled = true
    }
}

final class ProfileViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterSetProfileAndImage() {
        // given
        let expectation = expectation(description: "Loading expectation")
        let profile = Profile(
            username: "username",
            name: "name",
            loginName: "login",
            bio: "bio")
        let avatarURL = "https://avatar.jpg"
        let avatar = UIImage(resource: ._0)

        let viewController = ProfileViewControllerSpy(expectation: expectation)
        let imageLoader = ImageLoaderStub(image: avatar)
        let profileService = ProfileServiceStub(profile: profile)
        let profileImageService = ProfileImageServiceStub(avatarURL: avatarURL)
        let logoutService = LogoutServiceSpy()
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            logoutService: logoutService,
            imageLoader: imageLoader)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.viewDidLoad()
        profileImageService.fetchProfileImageURL(username: profile.username, {_ in })

        // then
        waitForExpectations(timeout: 3)
        XCTAssertEqual(viewController.avatarShown, avatar)
        XCTAssertEqual(viewController.profileShown?.name, profile.name)
        XCTAssertEqual(imageLoader.urlRequested, URL(string: avatarURL))
    }

    func testPresenterLogout() {
        // given
        let viewController = ProfileViewControllerSpy(expectation: nil)
        let imageLoader = ImageLoaderStub(image: nil)
        let profileService = ProfileServiceStub(profile: nil)
        let profileImageService = ProfileImageServiceStub(avatarURL: nil)
        let logoutService = LogoutServiceSpy()
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            logoutService: logoutService,
            imageLoader: imageLoader)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.logout()

        // then
        XCTAssertTrue(viewController.showAlertCalled)
    }

    func testPresenterDoLogout() {
        // given
        let viewController = ProfileViewControllerSpy(expectation: nil)
        let imageLoader = ImageLoaderStub(image: nil)
        let profileService = ProfileServiceStub(profile: nil)
        let profileImageService = ProfileImageServiceStub(avatarURL: nil)
        let logoutService = LogoutServiceSpy()
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            logoutService: logoutService,
            imageLoader: imageLoader)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.doLogout()

        // then
        XCTAssertTrue(viewController.switchCalled)
        XCTAssertTrue(logoutService.logoutCalled)
    }
}
