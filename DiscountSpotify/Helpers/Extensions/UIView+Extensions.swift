//
//  UIView+Extensions.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/11/21.
//

import UIKit

extension UIView  {
    func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
