//
//  LogInController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 11/12/20.
//

import UIKit
import AuthenticationServices
import SnapKit
import Spartan

class LogInController: UIViewController, ASWebAuthenticationPresentationContextProviding {

    var coordinator: AppCoordinator!

    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loginpage2")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let spotifyLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spotifylogo")?.withTintColor(.blueCola).withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private let opacityView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        return view
    }()
    
    private let spotifyLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.text = "Discount Spotify"
        label.font = systemFont
        label.textAlignment = .center
        label.textColor = .blueCola
        return label
    }()
    
    private let logInSpotifyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .blueCola
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(logInSpotifyButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    fileprivate func setupViews() {
        self.view.backgroundColor = .systemBackground
        
//        self.view.addSubview(backgroundImage)
//        backgroundImage.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        backgroundImage.addSubview(opacityView)
//        opacityView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        opacityView.addSubview(spotifyLogoImage)
//        spotifyLogoImage.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.centerY.equalToSuperview().dividedBy(2.7)
//            $0.height.width.equalTo(170)
//        }
//
//        opacityView.addSubview(spotifyLabel)
//        spotifyLabel.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.top.equalTo(spotifyLogoImage.snp.bottom).offset(-30)
//            $0.height.equalTo(100)
//        }
//
//        opacityView.addSubview(logInSpotifyButton)
//        logInSpotifyButton.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.height.equalTo(50)
//            $0.width.equalToSuperview().multipliedBy(0.75)
//            $0.bottom.equalToSuperview().offset(-100)

        self.view.addSubview(spotifyLogoImage)
        spotifyLogoImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().dividedBy(2.7)
            $0.height.width.equalTo(170)
        }

        self.view.addSubview(spotifyLabel)
        spotifyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(spotifyLogoImage.snp.bottom).offset(-30)
            $0.height.equalTo(100)
        }
        
        self.view.addSubview(logInSpotifyButton)
        logInSpotifyButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.bottom.equalToSuperview().offset(-100)
        }
    }
    
    @objc private func logInSpotifyButtonTapped() {
        print("pressed")
        authenticate()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
    
    func authenticate() {
        let scopeAsString = NetworkManager.stringScopes.joined(separator: "%20")
        let url = URL(string: "https://accounts.spotify.com/authorize?client_id=\(NetworkManager.clientId)&response_type=code&redirect_uri=\(NetworkManager.redirectURI)&scope=\(scopeAsString)")!
        let scheme = "auth"
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) { (callbackUrl, error) in
            guard let callbackUrl = callbackUrl, error == nil else { return }
            let queryItems = URLComponents(string: callbackUrl.absoluteString)?.queryItems
            
            guard let requestToken = queryItems?.first(where: { $0.name == "code" })?.value else { return }
            NetworkManager.authorizationCode = requestToken
            NetworkManager.fetchAccessToken { (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                case .success(let spotifyAuth):
                    NetworkManager.getUser(accessToken: spotifyAuth.accessToken) { (result) in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(let user):
                            self.coordinator.goToHomeController()
                        }
                    }
                }
            }
        
        }
        session.presentationContextProvider = self
        session.start()
    }
}


