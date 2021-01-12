//
//  SceneDelegate.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 11/12/20.
//

import UIKit
import Spartan

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator!
    lazy var loginController = LogInController()
    
    //MARK: Spotify Properties
    
    var playURI: String = ""
    var lastPlayerState: SPTAppRemotePlayerState?
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: NetworkManager.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = SpotifyAuth.current?.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        window!.windowScene = windowScene
        coordinator = AppCoordinator(window: window!)
        configureRootViewController()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let parameters = loginController.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            NetworkManager.authorizationCode = code
            loginController.coordinator = coordinator
            loginController.fetchSpotifyAccessToken()
        } else if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            if var spotifyAuth = SpotifyAuth.current {
                spotifyAuth.accessToken = accessToken
                SpotifyAuth.setCurrent(spotifyAuth, writeToUserDefaults: true)
            } else {
                let spotifyAuth = SpotifyAuth(tokenType: nil, refreshToken: nil, accessToken: accessToken, expiresIn: nil, scope: nil)
                SpotifyAuth.setCurrent(spotifyAuth, writeToUserDefaults: true)
            }
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
}

extension SceneDelegate {
    func configureRootViewController() {
        if let _ = User.current, let refreshToken = SpotifyAuth.current?.refreshToken  { //if we have a user, then go to home
            if let accessToken = SpotifyAuth.current?.accessToken {
                NetworkManager.getUser(accessToken: accessToken) { (result) in
                    switch result {
                    case .failure(let error):
                        print("couldn't fetch user \(error.localizedDescription)")
                    case .success(let user):
                        let user = User(user: user)
                        User.setCurrent(user, writeToUserDefaults: true)
                        print("Got user \(user.name)")
                        self.coordinator.goToHomeController()
                    }
                }
            } else {
                NetworkManager.authorizationCode = refreshToken
                NetworkManager.fetchAccessToken { (result) in
                    switch result {
                    case .failure(let error):
                        print("couldn't fetch access token \(error.localizedDescription)")
                    case .success(let spotifyAuth):
                        NetworkManager.getUser(accessToken: spotifyAuth.accessToken) { (result) in
                            DispatchQueue.main.async {
                                switch result {
                                case .failure(let error):
                                    print("couldn't fetch user \(error.localizedDescription)")
                                case .success(let user):
                                    let user = User(user: user)
                                    User.setCurrent(user, writeToUserDefaults: true)
                                    print("Got user \(user.name)")
                                    self.coordinator.goToHomeController()
                                }
                            }
                        }
                    }
                }
            }
        } else {
            //go to log in
            UserDefaults.standard.set(true, forKey: "firstTime")
            coordinator.goToLogInController()
        }
    }
}

//MARK: Spotify Methods
extension SceneDelegate {
    func connect() {
        self.appRemote.authorizeAndPlayURI(self.playURI)
    }
}

extension SceneDelegate: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        self.appRemote = appRemote
        self.appRemote.playerAPI?.pause(nil)
//        tabBarController.appRemoteConnected()
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
//        tabBarController.appRemoteDisconnect()
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
//        tabBarController.appRemoteDisconnect()
    }
}

extension SceneDelegate: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        tabBarController.playerStateDidChange(playerState)
//        tabBarController.appRemoteConnected()
    }
}

