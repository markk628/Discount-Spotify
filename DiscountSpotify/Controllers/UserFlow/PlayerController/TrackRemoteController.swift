//
//  TrackRemoteController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/11/21.
//

import UIKit
import SnapKit
import Spartan

class TrackRemoteController: UIViewController, TrackSubscriber {
    
    var currentTrack: Track? {
        didSet {
            configureFields()
        }
    }
    
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var TrackNameLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.font = systemFont
        label.textColor = .lightCyan
        return label
    }()
    
    lazy var albumNameLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.font = systemFont
        label.textColor = .lightCyan
        return label
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 24
        return stackView
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play")?.withTintColor(.fluorescentBlue).withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
//        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        return button
    }()

    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "suit.heart"), for: .normal)
//        button.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureFields()
    }
}

// MARK: - Internal
extension TrackRemoteController {
    
    func setupViews() {
        self.view.backgroundColor = .clear
        
        self.view.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
        }
        
        [TrackNameLabel, albumNameLabel].forEach {
            verticalStackView.addArrangedSubview($0)
        }
        
        self.view.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(albumNameLabel).offset(40)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }
    
    func configureFields() {
        guard TrackNameLabel != nil else {
            return
        }
        
        TrackNameLabel.text = currentTrack?.name
        albumNameLabel.text = currentTrack?.album.name
    }
}
