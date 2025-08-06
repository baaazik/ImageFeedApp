//
//  ViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 15.05.2025.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    func showNewPhotos(rows: [IndexPath])
    func showProgress()
    func hideProgress()
    func setLike(row: Int, isLiked: Bool)
    func showError(message: String)
    func openImage(url: String)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {

    @IBOutlet private var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let placeholder = UIImage(resource: .stub)

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    var presenter: ImagesListViewPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let presenter else { return }

        let photo = presenter.photo(at: indexPath.row)

        cell.photoImageView.kf.indicatorType = .activity
        cell.photoImageView.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: placeholder)

        if let createdAt = photo.createdAt {
            cell.dateText.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateText.text = ""
        }

        cell.likeButton.accessibilityIdentifier = "Like"

        cell.setIsLiked(isLiked: photo.isLiked)

        cell.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let url = sender as? String,
                let presenter
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    func showNewPhotos(rows: [IndexPath]) {
        tableView.performBatchUpdates {
            self.tableView.insertRows(at: rows, with: .automatic)
        } completion: { _ in }
    }

    func showProgress() {
        UIBlockingProgressHUD.show()
    }

    func hideProgress() {
        UIBlockingProgressHUD.dismiss()
    }

    func setLike(row: Int, isLiked: Bool) {
        let indexPath = IndexPath(row: row, section: 0)
        guard
            let cell = tableView.cellForRow(at: indexPath),
            let imageListCell = cell as? ImagesListCell else {
            return
        }

        imageListCell.setIsLiked(isLiked: isLiked)
    }

    func showError(message: String) {
        showErrorAlert(on: self, title: "Ошибка", message: message)
    }

    func openImage(url: String) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: url)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount() ?? 0
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
        presenter?.didSelectImage(row: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter else { return 0 }
        let photo = presenter.photo(at: indexPath.row)

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
            presenter?.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard
            let indexPath = tableView.indexPath(for: cell),
            let presenter
        else { return }
        presenter.didLikeImage(row: indexPath.row)
    }
}
