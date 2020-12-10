//
//  ProfileController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit

class ProfileController: UIViewController {
    
    var coordinator: TabBarCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "Profile"
    }
}
