//
//  MiniPlayerView.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/12/21.
//

import UIKit
import SnapKit
import Spartan
import AVFoundation
import Kingfisher

class MiniPlayerView: UIView, TrackSubscriber {
    
    var player: AVPlayer?
    var store = CoreDataStack(modelName: "DiscountSpotify")
    var currentTrack: Track?
    
    var spartanCallbackError: (Error?) -> () {
        get {
            return {[weak self] error in
                if let error = error {
//                    self?.presentAlert(title: "Error", message: error.localizedDescription)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private let opacityView: UIView = {
        let view = UIView()
        view.addBlur()
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var trackStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var trackNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .electricBlue
        label.font = label.font.withSize(15)
        label.textAlignment = .left
        return label
    }()
    
    lazy var albumNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .electricBlue
        label.font = label.font.withSize(12)
        label.textAlignment = .left
        return label
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play")?.withTintColor(.fluorescentBlue).withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        button.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configure(track: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {

        self.addSubview(opacityView)
        opacityView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        opacityView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        [albumImageView, trackStackView, favoriteButton, playButton].forEach {
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.height.centerY.equalToSuperview()
            }
        }
        albumImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.width.equalTo(albumImageView.snp.height)
        }

        trackStackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.50)
        }

        [favoriteButton, playButton].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(self.albumImageView.snp.height).multipliedBy(0.8)
            }
        }

        [trackNameLabel, albumNameLabel].forEach {
            trackStackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalToSuperview().multipliedBy(0.5)
            }
        }
    }
    
    func retrieveAudioPreview() {
        let urlString = currentTrack?.previewUrl
        guard let url = URL.init(string: urlString!) else { return }
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
    }
    
    func configure(track: Track?) {
        if let track = track {
            trackNameLabel.text = track.name
            albumNameLabel.text = track.album.name
            downloadImage(track: track)
        } else {
            trackNameLabel.text = nil
            albumNameLabel.text = nil
            albumImageView.image = nil
            print("nothing")
        }
        currentTrack = track
    }
    
    func downloadImage(track: Track) {
        guard let urlString = track.album?.images.first?.url,
              let imageUrl = URL(string: urlString) else { return }
        albumImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil) { (receivedSize, totalSize) in
            
        } completionHandler: { (result) in
            do {
                let _ = try result.get()
                print("got something")
            } catch {
               
            }
        }
    }
}

extension MiniPlayerView {
    
    @objc func playButtonPressed() {
        retrieveAudioPreview()
        player?.play()
    }
    
    @objc func favoriteButtonPressed() {
//        let newTrack = FavTracks(context: store.mainContext)
//        newTrack.trackCoreData = (currentTrack?.id as! String)
//        store.saveContext()
        
        Spartan.saveTracks(trackIds: [currentTrack?.id as! String], success: nil, failure: spartanCallbackError)
    }
}
