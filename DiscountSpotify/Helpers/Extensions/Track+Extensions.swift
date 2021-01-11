//
//  Track+Extensions.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/10/21.
//

import UIKit
import Spartan

extension Track {
    
    func loadSongImage(completion: @escaping ((UIImage?) -> (Void))) {
        guard let imageURL = self.album?.images.first?.url,
              let file = Bundle.main.path(forResource: imageURL, ofType:"jpg") else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let image = UIImage(contentsOfFile: file)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
