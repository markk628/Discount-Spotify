//
//  SpotifyAuth.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/9/20.
//

import Foundation

struct SpotifyAuth {
    public let tokenType: String
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let scope: String
}

extension SpotifyAuth: Codable {}
