//
//  AppCoordinator.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit

class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    lazy var navigationController: UINavigationController = UINavigationController()
    
    init(window: UIWindow) {
        window.rootViewController = navigationController
        setupNavigationController()
    }
    
    func start() {
        let vc = LogInController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    @objc func goToLogInController() {
        let vc = LogInController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToHomeController() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.start()
    }
}

private extension AppCoordinator {
    func setupNavigationController() {
        self.navigationController.isNavigationBarHidden = true
    }
}
