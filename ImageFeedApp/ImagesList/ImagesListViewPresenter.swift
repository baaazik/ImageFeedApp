//
//  ImageListViewPresenter.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 05.08.2025.
//

import Foundation

protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func didLikeImage(row: Int)
    func didSelectImage(row: Int)
    func photo(at: Int) -> Photo
    func photosCount() -> Int
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    private var imageServiceObserver: NSObjectProtocol?
    private let imageListService: ImageListServiceProtocol
    private var photos: [Photo] = []

    var view: ImagesListViewControllerProtocol?

    init(imageListService: ImageListServiceProtocol) {
        self.imageListService = imageListService
    }

    func viewDidLoad() {
        imageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updatePhotos()
            }

        imageListService.fetchPhotosNextPage()
    }

    func fetchPhotosNextPage() {
        imageListService.fetchPhotosNextPage()
    }

    func didLikeImage(row: Int) {
        guard let view else { return }

        let photo = photos[row]

        view.showProgress()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                view.setLike(row: row, isLiked: self.photos[row].isLiked)
                view.hideProgress()
            case .failure:
                view.hideProgress()
                view.showError(message: "Не удалось поставить лайк")
            }
        }
    }

    func didSelectImage(row: Int) {
        let photo = photos[row]
        view?.openImage(url: photo.largeImageURL)
    }

    func photo(at: Int) -> Photo {
        photos[at]
    }

    func photosCount() -> Int {
        photos.count
    }

    private  func updatePhotos() {
        var rows: [IndexPath] = []

        for i in photos.count..<imageListService.photos.count {
            rows.append(IndexPath(row: i, section: 0))
        }

        photos = imageListService.photos
        view?.showNewPhotos(rows: rows)
    }
}
