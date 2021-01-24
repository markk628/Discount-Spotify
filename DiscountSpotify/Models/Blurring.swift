//
//  Blurring.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/23/21.
//

import UIKit

protocol Blurring {
    func addBlur(_ alpha: CGFloat)
}

extension Blurring where Self: UIView {
    func addBlur(_ alpha: CGFloat = 0.8) {
        let effect = UIBlurEffect(style: .prominent)
        let effectView = UIVisualEffectView(effect: effect)
        
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha
        
        self.addSubview(effectView)
    }
}

extension UIView: Blurring { }
