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
}
