//
//  SpotifyAuth.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/9/20.
//

import Foundation

struct SpotifyAuth {
    public let tokenType: String?
    public let refreshToken: String?
    public var accessToken: String
    public var expiresIn: Int?
    public var scope: String?
    
    private static var _current: SpotifyAuth?
    static var current: SpotifyAuth? {
        // Check if current user (tenant) exist
        if let currentSpotifyAuth = _current {
            return currentSpotifyAuth
        } else {
            // Check if the user was saved in UserDefaults. If not, return nil
            guard let spotifyAuth = UserDefaults.standard.getStruct(SpotifyAuth.self, forKey: Constants.spotifyAuthKey) else { return nil }
            _current = spotifyAuth
            return spotifyAuth
        }
    }
}

extension SpotifyAuth: Codable {}

extension SpotifyAuth {
    static func setCurrent(_ spotifyAuth: SpotifyAuth, writeToUserDefaults: Bool = false) {
        // Save user's information in UserDefaults excluding passwords and sensitive (private) info
        if writeToUserDefaults {
            UserDefaults.standard.setStruct(spotifyAuth, forKey: Constants.spotifyAuthKey)
        }
        _current = spotifyAuth
    }
    
    static func removeCurrent(_ removeFromUserDefaults: Bool = false) {
        if removeFromUserDefaults {
            Defaults._removeSpotifyAuth(true)
        }
        _current = nil
    }
}
