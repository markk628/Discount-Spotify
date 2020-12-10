//
//  TabBarCoordinator.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit
import Spartan

class TabBarCoordinator: NSObject, UITabBarControllerDelegate, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var homeNavigationController: UINavigationController!
    var favoritesNavigationController: UINavigationController!
    var profileNavigationController: UINavigationController!
    var tabBarController = TabBarController()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        tabBarController.coordinator = self
        tabBarController.delegate = self
        
        let homeController = HomeController()
        homeController.coordinator = self
        homeNavigationController = UINavigationController(rootViewController: homeController)
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), tag: 0)
        
        let favoritesController = FavoritesController()
        favoritesController.coordinator = self
        favoritesNavigationController = UINavigationController(rootViewController: favoritesController)
        favoritesNavigationController.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(named: "heart"), tag: 1)
        
        let profileController = ProfileController()
        profileController.coordinator = self
        profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "user"), tag: 2)
        
        tabBarController.viewControllers = [homeNavigationController, favoritesNavigationController, profileNavigationController]
        
        tabBarController.modalPresentationStyle = .fullScreen
        tabBarController.setupNavigationController()
        navigationController.present(tabBarController, animated: false, completion: nil)
    }
}

extension TabBarCoordinator {
    func goToHomeController() {
        tabBarController.selectedIndex = 0
    }
    
    func goToFavoritesController() {
        tabBarController.selectedIndex = 1
    }
    
    func goToProfileController() {
        tabBarController.selectedIndex = 2
    }
    
    func goToArtistControllerHome(artist: Artist) {
        let vc = ArtistController()
        vc.artist = artist
        vc.coordinator = self
        homeNavigationController.pushViewController(vc, animated: true)
    }
    
    func goToTrackControllerHome(track: Track) {
        let vc = TrackController()
        vc.track = track
        vc.coordinator = self
        homeNavigationController.pushViewController(vc, animated: true)
    }
    
    func goToTrackControllerFavorite(track: Track) {
        let vc = TrackController()
        vc.track = track
        vc.coordinator = self
        favoritesNavigationController.pushViewController(vc, animated: true)
    }
}
