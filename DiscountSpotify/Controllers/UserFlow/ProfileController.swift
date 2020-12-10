//
//  ProfileController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit
import Spartan
import Kingfisher

class ProfileController: UIViewController {
    
    var coordinator: TabBarCoordinator!
    var user: PrivateUser!
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var userNameAndTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.font = systemFont
        label.textColor = .lightCyan
        return label
    }()
    
    lazy var userAccountType: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.font = systemFont
        label.textColor = .lightCyan
        return label
    }()
    
    lazy var userFollowersLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.font = systemFont
        label.textColor = .lightCyan
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.createGradientLayer(vc: self)
        self.title = "Profile"
        getUser()
        
        self.view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
        [userProfileImageView, userNameAndTypeStackView,userFollowersLabel].forEach {
            mainStackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalToSuperview()
            }
        }
        userProfileImageView.snp.makeConstraints {
            $0.height.equalTo(userProfileImageView.snp.width)
        }
        
        [userNameLabel, userAccountType].forEach {
            userNameAndTypeStackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.5)
            }
        }
    }
    
    func getUser() {
        NetworkManager.getProfileInfo { (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlert(title: "Error Getting You", message: error.localizedDescription)
                    print(error.localizedDescription)
                }
            case .success(let accountInfo):
                DispatchQueue.main.async {
                    self.populateViews(account: accountInfo)
                }
            }
        }
    }
    
    func populateViews(account: PrivateUser) {
        userNameLabel.text = account.displayName
        guard let urlString = account.images?.first?.url,
              let imageUrl = URL(string: urlString) else { return }
        userProfileImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil) { (receivedSize, totalSize) in
            
        } completionHandler: { (result) in
            do {
                let _ = try result.get()
            } catch {
                DispatchQueue.main.async {
                    print("Downloaded ya face")
                }
            }
        }

    }
}
