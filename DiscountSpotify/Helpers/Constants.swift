//
//  Constants.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 11/12/20.
//

import Foundation

let scopes: SPTScope = [.userReadEmail,
                        .userReadPrivate,
                        .userReadPlaybackState,
                        .userModifyPlaybackState,
                        .userReadCurrentlyPlaying,
                        .streaming,
                        .appRemoteControl,
                        .playlistReadCollaborative,
                        .playlistModifyPublic,
                        .playlistReadPrivate,
                        .playlistModifyPrivate,
                        .userLibraryModify,
                        .userLibraryRead,
                        .userTopRead,
                        .userReadPlaybackState,
                        .userReadCurrentlyPlaying,
                        .userFollowRead,
                        .userFollowModify,]

struct Constants {
    static let clientID = "e084d42ace1c4befad592ea4649eece5"
    static let redirectURI = URL(string: "discountspotify://")!
    static let clientSecret = "1c678b58b9c4496e8ed066f9d4b921ea"
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
    static let currentUser = "currentUser"
    static let accessTokenKey = "accessTokenKey"
    static let authorizationCodeKey = "authorizationCodeKey"
    static let refreshTokenKey = "refreshTokenKey"
    static let spotifyAuthKey = "spotifyAuthKey"
}
