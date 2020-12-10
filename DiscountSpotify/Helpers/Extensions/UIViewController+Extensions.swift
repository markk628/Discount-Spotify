//
//  UIViewController+Extensions.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/8/20.
//

import UIKit.UIViewController

extension UIViewController {
    func presentAlert(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createGradientLayer(vc: UIViewController) {
        let gradientLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.frame = self.view.bounds
            layer.colors = [UIColor.blueCola.cgColor, UIColor.black.cgColor]
            layer.startPoint = CGPoint(x: 0, y: 1)
            layer.endPoint = CGPoint(x: 0.5, y: 0.5)
            return layer
        }()
        
        vc.view.layer.addSublayer(gradientLayer)
    }
}
