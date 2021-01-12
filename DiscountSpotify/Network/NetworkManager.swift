//
//  NetworkManager.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/8/20.
//

import Foundation
//import AuthenticationServices
import Spartan

class NetworkManager {
    
    public static let shared = NetworkManager()
    private init() {}
    
    static private let baseURL: String = "https://accounts.spotify.com/"
    static private let defaults: UserDefaults = UserDefaults.standard
    static private var parameters: [String: String] = [:]
    
    static let urlSession: URLSession = URLSession.shared
    static let clientId: String = "e084d42ace1c4befad592ea4649eece5"
    static let clientSecret: String = "1c678b58b9c4496e8ed066f9d4b921ea"
    static let redirectURI: URL = URL(string: "discountspotify://")!
    static let accessTokenKey: String = "accessTokenKey"
    static let authorizationCodeKey: String = "authorizationCodeKey"
    static let refreshTokenKey: String = "refreshTokenKey"
    static let stringScopes: [String] = [
        "user-read-email", "user-read-private",
        "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
        "streaming", "app-remote-control",
        "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
        "user-library-modify", "user-library-read",
        "user-top-read", "user-read-playback-position", "user-read-recently-played",
        "user-follow-read", "user-follow-modify",
    ]
    
    static var totalCount: Int = Int.max
    static var codeVerifier: String = ""
    
    static var accessToken = defaults.string(forKey: accessTokenKey) {
        didSet { defaults.set(accessToken, forKey: accessTokenKey) }
    }
    static var authorizationCode = defaults.string(forKey: authorizationCodeKey) {
        didSet { defaults.set(authorizationCode, forKey: authorizationCodeKey)}
    }
    static var refreshToken = defaults.string(forKey: refreshTokenKey) {
        didSet { defaults.set(refreshToken, forKey: refreshTokenKey) }
    }
    
    static let configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: clientId, redirectURL: redirectURI)
        configuration.playURI = ""
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    
//    static func fetchAccessToken(completion: @escaping (Result<SpotifyAuth, Error>) -> Void) {
//        guard let code = authorizationCode else {
//            return completion(.failure(ErrorMessage.missing(message: "WHERE'S THE LAMB SAUCE! (lambSauce = authCode)")))
//        }
//        let url = URL(string: "\(baseURL)api/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let spotifyAuthKey = "Basic \((clientId + ":" + clientSecret).data(using: .utf8)!.base64EncodedString())"
//        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey, "Content-Type": "application/x-www-form-urlencoded"]
//        var requestBodyComponents = URLComponents()
//        let scopeAsString = stringScopes.joined(separator: " ")
//        requestBodyComponents.queryItems = [
//            URLQueryItem(name: "client_id", value: clientId),
//            URLQueryItem(name: "grant_type", value: "authorization_code"),
//            URLQueryItem(name: "code", value: code),
//            URLQueryItem(name: "redirect_uri", value: redirectURI),
//            URLQueryItem(name: "code_verifier", value: codeVerifier),
//            URLQueryItem(name: "scope", value: scopeAsString),
//        ]
//        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
//        let task = urlSession.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                  let response = response as? HTTPURLResponse,
//                  (200 ..< 300) ~= response.statusCode,
//                  error == nil else {
//                return completion(.failure(ErrorMessage.noData(message: "WHERE'S THE LAMB SAUCE! (data)")))
//            }
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            do {
//                guard let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) else {
//                    return completion(.failure(ErrorMessage.couldNotParse(message: "Failed to decode data")))
//                }
//                self.accessToken = spotifyAuth.accessToken
//                self.authorizationCode = nil
//                self.refreshToken = spotifyAuth.refreshToken
//                return completion(.success(spotifyAuth))
//            }
//        }
//        task.resume()
//    }
//
//    static func refreshAccessToken(completion: @escaping (Result<SpotifyAuth, Error>) -> Void) {
//        guard let refreshToken = refreshToken else {
//            return completion(.failure(ErrorMessage.missing(message: "WHERE'S THE LAMB SAUCE! (refresh token)")))
//        }
//        let url = URL(string: "\(baseURL)api/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let spotifyAuthKey = "Basic \((clientId + ":" + clientSecret).data(using: .utf8)!.base64EncodedString())"
//        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey, "Content-Type": "application/x-www-form-urlencoded"]
//        var requestBodyComponents = URLComponents()
//        requestBodyComponents.queryItems = [
//            URLQueryItem(name: "grant_type", value: "refresh_token"),
//            URLQueryItem(name: "refresh_token", value: refreshToken),
//            URLQueryItem(name: "client_id", value: clientId),
//        ]
//        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
//        let task = urlSession.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                  let response = response as? HTTPURLResponse,
//                  (200 ..< 300) ~= response.statusCode,
//                  error == nil else {
//                return completion(.failure(ErrorMessage.noData(message: "WHERE'S THE LAMB SAUCE! (data)")))
//            }
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            do {
//                guard let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) else {
//                    return completion(.failure(ErrorMessage.couldNotParse(message: "Failed to decode data")))
//                }
//                self.accessToken = spotifyAuth.accessToken
//                return completion(.success(spotifyAuth))
//            }
//        }
//        task.resume()
//    }
    
    
    
    
    static func fetchAccessToken(completion: @escaping (Result<SpotifyAuth, Error>) -> Void) {
        guard let code = authorizationCode else { return completion(.failure(ErrorMessage.missing(message: "No authorization code found."))) }
        let url = URL(string: "\(baseURL)api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authorizationValue = "Basic \((clientId + ":" + clientSecret).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": authorizationValue,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ") //put array to string separated by whitespace
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "code_verifier", value: codeVerifier),
            URLQueryItem(name: "scope", value: scopeAsString),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                return completion(.failure(ErrorMessage.noData(message: "No data found")))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase  //convert keys from snake case to camel case
            do {
                if let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) {
//                    self.accessToken = spotifyAuth.accessToken
//                    self.spotifyAuth = spotifyAuth
                    SpotifyAuth.setCurrent(spotifyAuth, writeToUserDefaults: true)
                    self.authorizationCode = nil
//                    self.refreshToken = spotifyAuth.refreshToken
                    Spartan.authorizationToken = spotifyAuth.accessToken
                    return completion(.success(spotifyAuth))
                }
                completion(.failure(ErrorMessage.couldNotParse(message: "Failed to decode data")))
            }
        }
        task.resume()
    }
    
    static func refreshAccessToken(completion: @escaping (Result<SpotifyAuth, Error>) -> Void) {
        guard let refreshToken = SpotifyAuth.current?.refreshToken else { return completion(.failure(ErrorMessage.missing(message: "No refresh token found."))) }
        let url = URL(string: "\(baseURL)api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((clientId + ":" + clientSecret).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: clientId),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                return completion(.failure(ErrorMessage.noData(message: "No data found")))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase  //convert keys from snake case to camel case
            do {
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
//                print(jsonResult)
                if let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) {
                    //update access token
//                    self.accessToken = spotifyAuth.accessToken
//                    self.spotifyAuth?.accessToken = spotifyAuth.accessToken
                    guard var spotifyAuthToUpdate = SpotifyAuth.current else { return }
                    spotifyAuthToUpdate.accessToken = spotifyAuth.accessToken
                    spotifyAuthToUpdate.expiresIn = spotifyAuth.expiresIn
                    spotifyAuthToUpdate.scope = spotifyAuth.scope
                    SpotifyAuth.setCurrent(spotifyAuthToUpdate, writeToUserDefaults: true)
                    Spartan.authorizationToken = spotifyAuth.accessToken
                    print("Refreshed Access Token: \(spotifyAuth.accessToken)")
                    return completion(.success(spotifyAuth))
                }
                completion(.failure(ErrorMessage.couldNotParse(message: "Failed to decode data")))
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
    static func getUser(accessToken: String, completion: @escaping (Result<PrivateUser, Error>) -> Void) {
        Spartan.authorizationToken = accessToken
        Spartan.getMe(success: { (spartanUser) in
            completion(.success(spartanUser))
        }, failure: { (error) in
            if error.errorType == .unauthorized {
                return
            }
            completion(.failure(error))
        })
    }
    
    static func getMyTopArtists(offset: Int, completion: @escaping (Result<[Artist], Error>) -> Void) {
        Spartan.getMyTopArtists(limit: 50, offset: offset, timeRange: .longTerm, success: { (pagingObject) in
            completion(.success(pagingObject.items))
        }, failure: { (error) in
            completion(.failure(error))
        })
    }
    
    static func getArtistTopTracks(artistId: String, country: CountryCode = .us, completion: @escaping (Result<[Track], Error>) -> Void) {
        Spartan.getArtistsTopTracks(artistId: artistId, country: country) { (tracks) in
            completion(.success(tracks))
        } failure: { (error) in
            completion(.failure(error))
        }
    }
    
    static func getFavoriteTracks(offset: Int, completion: @escaping (Result<[SavedTrack], Error>) -> Void) {
        Spartan.getSavedTracks(limit: 50, offset: offset, market: .us) { (pagingObject) in
            completion(.success(pagingObject.items))
        } failure: { (error) in
            completion(.failure(error))
        }
    }
    
    static func getCoreDataTracks(ids: [String], market: CountryCode = .us, completion: @escaping (Result<[Track], Error>) -> Void) {
        Spartan.getTracks(ids: ids, market: market) { (tracks) in
            completion(.success(tracks))
        } failure: { (error) in
            completion(.failure(error))
        }
    }
    
    static func getProfileInfo(completion: @escaping (Result<PrivateUser, Error>) -> Void) {
        Spartan.getMe { (user) in
            completion(.success(user))
        } failure: { (error) in
            completion(.failure(error))
        }
        
    }
}
