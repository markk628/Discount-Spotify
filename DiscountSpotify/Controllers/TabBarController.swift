//
//  TabBarController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit

class TabBarController: UITabBarController {
    
    var coordinator: TabBarCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
        
    }
}

extension TabBarController {
    func setupNavigationController() {
        for i in 0...2 {
            guard let navVC = self.viewControllers?[i] as? UINavigationController else { return }
            navVC.navigationBar.prefersLargeTitles = true
            navVC.navigationBar.barTintColor = .black
            navVC.navigationBar.tintColor = .electricBlue
            navVC.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.electricBlue]
            navVC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.electricBlue]
        }
    }
    
    func setupTabBarController() {
        self.tabBar.barTintColor = .black
        self.tabBar.tintColor = .electricBlue
    }
}
