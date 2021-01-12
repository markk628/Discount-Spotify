//
//  MiniPlayerController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/10/21.
//

import UIKit
import SnapKit
import Spartan

protocol MiniPlayerDelegate: class {
    func expandTrack(track: Track)
}

class MiniPlayerController: UIViewController, TrackSubscriber {
    
    //MARK: Properties
    var currentTrack: Track?
    weak var delegate: MiniPlayerDelegate?
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
    
    private lazy var visualEffectsView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        
        return view
    }()
    
//    private lazy var stackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.alignment = .center
//        stackView.distribution = .fillProportionally
//        stackView.spacing = 10
//        return stackView
//    }()
    
    lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
//    lazy var trackStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.distribution = .fill
//        return stackView
//    }()
    
    lazy var trackNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .electricBlue
        label.font = label.font.withSize(20)
        label.textAlignment = .left
        return label
    }()
    
    lazy var albumNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .electricBlue
        label.font = label.font.withSize(15)
        label.textAlignment = .left
        return label
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
        self.view.addGestureRecognizer(tap)
        setupViews()
        configure(track: nil)
    }
    
    private func setupViews() {
        self.view.backgroundColor = .clear
        
//        self.view.addSubview(stackView)
//        stackView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        [albumImageView, trackStackView, favoriteButton, playButton].forEach {
//            stackView.addArrangedSubview($0)
//            $0.snp.makeConstraints {
//                $0.height.centerY.equalToSuperview()
//            }
//        }
//
//        trackStackView.snp.makeConstraints {
//            $0.width.equalToSuperview().multipliedBy(0.57)
//        }
//
//        [albumImageView, favoriteButton, playButton].forEach {
//            $0.snp.makeConstraints {
//                $0.width.equalTo(self.albumImageView.snp.height)
//            }
//        }
//
//        [trackNameLabel, albumNameLabel].forEach {
//            trackStackView.addArrangedSubview($0)
//            $0.snp.makeConstraints {
//                $0.height.equalToSuperview().multipliedBy(0.5)
//            }
//        }
        
        self.view.addSubview(visualEffectsView)
        visualEffectsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        self.view.addSubview(albumImageView)
        albumImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.equalTo(albumImageView.snp.height)
        }
        
        self.view.addSubview(trackNameLabel)
        trackNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(albumImageView.snp.right).offset(16)
        }
        
        visualEffectsView.contentView.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-8)
        }
        
        visualEffectsView.contentView.addSubview(playButton)
        playButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(favoriteButton.snp.left).offset(-8)
        }
    }
}

// MARK: - Internal
extension MiniPlayerController {
    
    func configure(track: Track?) {
        if let track = track {
            trackNameLabel.text = track.name
            track.loadSongImage { [weak self] (image) -> (Void) in
                self?.albumImageView.image = image
            }
        } else {
            trackNameLabel.text = nil
            albumImageView.image = nil
        }
        currentTrack = track
    }
}

// MARK: - IBActions
extension MiniPlayerController {
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer? = nil) {
        guard let track = currentTrack else {
            return
        }
        delegate?.expandTrack(track: track)
    }
}

// MARK: - MaxPlayerSourceProtocol
extension MiniPlayerController: MaxPlayerSourceProtocol {
    
    var originatingFrameInWindow: CGRect {
        return view.convert(view.frame, to: nil)
    }
    
    var originatingCoverImageView: UIImageView {
        return albumImageView
    }
}
