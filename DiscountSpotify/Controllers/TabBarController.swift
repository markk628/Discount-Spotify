//
//  TabBarController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit
import SnapKit
import Spartan
import Kingfisher

class TabBarController: UITabBarController, TrackSubscriber {
    
    var coordinator: TabBarCoordinator!
    var currentTrack: Track?
    var store = CoreDataStack(modelName: "DiscountSpotify")

    
    lazy var miniPlayerContainerView: MiniPlayerView = {
        let view = MiniPlayerView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self exists
        setupTabBarController()
    }
}

// MARK: - IBActions
extension TabBarController {
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        guard let track = currentTrack else { return }
        let vc = TrackController()
        vc.track = track
        self.present(vc, animated: true)
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        miniPlayerContainerView.addGestureRecognizer(tap)
        
        self.tabBar.barTintColor = .black
        self.tabBar.tintColor = .electricBlue
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(miniPlayerContainerView)
        miniPlayerContainerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-80)
            $0.height.equalTo(65)
        }
    }
}

