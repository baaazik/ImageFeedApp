//
//  ViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 15.05.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImagesListService()
    private var imageServiceObserver: NSObjectProtocol?
    private let placeholder = UIImage(resource: .imagePlaceholder)

    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        imageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }

        imageListService.fetchPhotosNextPage()
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        cell.photoImageView.kf.indicatorType = .activity
        cell.photoImageView.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: placeholder)

        cell.dateText.text = dateFormatter.string(from: Date())

        let likeImage = indexPath.row % 2 == 0 ? ImageResource.activeLike : ImageResource.like
        cell.likeButton.setImage(UIImage(resource: likeImage), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            //let image = UIImage(named: photos[indexPath.row])
            //viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func updateTableViewAnimated() {
        var rows: [IndexPath] = []

        for i in photos.count..<imageListService.photos.count {
            rows.append(IndexPath(row: i, section: 0))
        }

        photos = imageListService.photos

        tableView.performBatchUpdates {
            self.tableView.insertRows(at: rows, with: .automatic)
        } completion: { _ in }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]

        let imageViewWidth = tableView.bounds.width - 2 * 16
        let imageViewHeight = (imageViewWidth * photo.size.height) / photo.size.width

        return imageViewHeight + 2 * 8
    }

    func tableView(
      _ tableView: UITableView,
      willDisplay cell: UITableViewCell,
      forRowAt indexPath: IndexPath
    ) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1

        if indexPath.row == lastRowIndex {
            imageListService.fetchPhotosNextPage()
        }
    }
}
