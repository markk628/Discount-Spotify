//
//  Defaults.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/10/21.
//

import Foundation

struct Defaults {
    private enum Keys {
        static let onboard = "onboard"
        static let cards = "cards"
        static let account = "account"
    }
    
    static var onboard: Bool {
        get { return UserDefaults.standard.bool(forKey: Keys.onboard) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.onboard)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var hasLoggedInOrCreatedAccount: Bool {
        get { return UserDefaults.standard.bool(forKey: Keys.account) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.account)
            UserDefaults.standard.synchronize()
        }
    }
    
    //MARK: Methods
    
    ///use after logging out
    static func _removeUser(_ removeFromUserDefaults: Bool = false) {
        if removeFromUserDefaults {
            UserDefaults.standard.removeObject(forKey: Constants.currentUser)
            //clear everything in UserDefaults
            UserDefaults.standard.deleteAllKeys(exemptedKeys: ["onboard"])
        }
    }
    
    ///use after logging out
    static func _removeSpotifyAuth(_ removeFromUserDefaults: Bool = false) {
        if removeFromUserDefaults {
            UserDefaults.standard.removeObject(forKey: Constants.spotifyAuthKey)
        }
    }
}
