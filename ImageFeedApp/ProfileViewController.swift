//
//  ProfileViewController.swift
//  ImageFeedApp
//
//  Created by Анжелика Забазнова on 26.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var accountText: UILabel!
    @IBOutlet weak var nameText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logoutAction(_ sender: Any) {
    }
    
}
