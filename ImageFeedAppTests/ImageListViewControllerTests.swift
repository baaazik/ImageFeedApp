//
//  ImageListViewControllerTests.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 05.08.2025.
//

@testable import ImageFeedApp
import XCTest

func makePhoto(_ id: String, isLiked: Bool = false) -> Photo {
    Photo(
        id: id,
        size: CGSize(),
        createdAt: Date(),
        welcomeDescription: "",
        thumbImageURL: "",
        largeImageURL: "",
        isLiked: isLiked)
}

final class ImageListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: (any ImageFeedApp.ImagesListViewPresenterProtocol)?
    var rowsInserted: Int?
    var showExpectation: XCTestExpectation?
    var likeExpectation: XCTestExpectation?
    var showProgressCalled = false
    var hideProgressCalled = false
    var likedPhoto: Int?
    var isLiked: Bool?
    var openImageCalled = false

    init(_ showExpectation: XCTestExpectation?, _ likeExpectation: XCTestExpectation?) {
        self.showExpectation = showExpectation
        self.likeExpectation = likeExpectation
    }

    func showNewPhotos(rows: [IndexPath]) {
        rowsInserted = rows.count
        showExpectation?.fulfill()
    }
    
    func showProgress() {
        showProgressCalled = true
    }
    
    func hideProgress() {
        hideProgressCalled = true
        likeExpectation?.fulfill()
    }
    
    func setLike(row: Int, isLiked: Bool) {
        self.likedPhoto = row
        self.isLiked = isLiked
    }
    
    func showError(message: String) {
    }
    
    func openImage(url: String) {
        openImageCalled = true
    }
}

final class ImageListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var view: (any ImageFeedApp.ImagesListViewControllerProtocol)?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
    }
    
    func didLikeImage(row: Int) {
    }
    
    func didSelectImage(row: Int) {
    }
    
    func photo(at: Int) -> ImageFeedApp.Photo {
        return makePhoto("0")
    }
    
    func photosCount() -> Int {
        return 0
    }
}

final class ImageListServiceStub: ImageListServiceProtocol {
    var photos: [ImageFeedApp.Photo]
    var fetchCalled = false
    var likedPhotoId: String?
    var likedPhotoState: Bool?

    init() {
        photos = [makePhoto("0"), makePhoto("1"), makePhoto("2")]
    }

    func fetchPhotosNextPage() {
        fetchCalled = true
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil,
            userInfo: ["photos": self.photos]
        )
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
        likedPhotoId = photoId
        likedPhotoState = isLike
        if let idx = photos.firstIndex(where: {$0.id == photoId}) {
            photos[idx] = makePhoto(photoId, isLiked: isLike)
        }
        completion(.success(()))
    }
}

final class ImageListViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImageListViewPresenterSpy()
        presenter.view = viewController
        viewController.presenter = presenter

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterDidLoad() {
        // given
        let expectation = expectation(description: "Show expectation")
        let imageListService = ImageListServiceStub()
        let presenter = ImagesListViewPresenter(imageListService: imageListService)
        let viewController = ImageListViewControllerSpy(expectation, nil)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.viewDidLoad()

        // then
        waitForExpectations(timeout: 3)
        XCTAssertTrue(imageListService.fetchCalled)
        XCTAssertEqual(viewController.rowsInserted, 3)
    }

    func testPresenterSetLike() {
        // given
        let expectation = expectation(description: "Like expectation")

        let imageListService = ImageListServiceStub()
        let presenter = ImagesListViewPresenter(imageListService: imageListService)
        let viewController = ImageListViewControllerSpy(nil, expectation)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.viewDidLoad()
        sleep(1)
        presenter.didLikeImage(row: 1)

        // then
        waitForExpectations(timeout: 3)
        XCTAssertEqual(imageListService.likedPhotoId, "1")
        XCTAssertEqual(imageListService.likedPhotoState, true)
        XCTAssertTrue(viewController.showProgressCalled)
        XCTAssertTrue(viewController.hideProgressCalled)
        XCTAssertEqual(viewController.likedPhoto, 1)
        XCTAssertEqual(viewController.isLiked, true)
    }

    func testPresenterDidSelectImage() {
        // given
        let imageListService = ImageListServiceStub()
        let presenter = ImagesListViewPresenter(imageListService: imageListService)
        let viewController = ImageListViewControllerSpy(nil, nil)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.viewDidLoad()
        sleep(1)
        presenter.didSelectImage(row: 1)

        // then
        XCTAssertTrue(viewController.openImageCalled)
    }
}
