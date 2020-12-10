//
//  Coordinator.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
