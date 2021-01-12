//
//  TrackController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/9/20.
//

import UIKit
import Spartan
import AVFoundation
import Kingfisher

class TrackController: UIViewController {

    var coordinator: TabBarCoordinator!
    var track: Track!
    var player: AVPlayer?
    var store = CoreDataStack(modelName: "DiscountSpotify")
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var albumNameLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.font = systemFont
        label.textColor = .lightCyan
        label.text = track.album.name
        return label
    }()
    
    lazy var trackSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .fluorescentBlue
        slider.addTarget(self, action: #selector(updateTrackSlider), for: .valueChanged)
        return slider
    }()
    
    lazy var playAndFavoriteButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }

    fileprivate func setupViews() {
        self.view.backgroundColor = .black
        self.title = track.name
        downloadImage()
        self.view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
            $0.width.equalToSuperview().multipliedBy(0.8)
        }

        [albumImageView, albumNameLabel, trackSlider, playAndFavoriteButtonStackView].forEach {
            mainStackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalToSuperview()
            }
        }
        albumImageView.snp.makeConstraints {
            $0.height.equalTo(albumImageView.snp.width)
        }
        
        [playButton, favoriteButton].forEach {
            playAndFavoriteButtonStackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.5)
            }
        }
    }
    
    @objc func playButtonPressed() {
        retrieveAudioPreview()
        player?.play()
    }
    
    @objc func favoriteButtonPressed() {
        let newTrack = FavTracks(context: store.mainContext)
        newTrack.trackCoreData = (track.id as! String)
        store.saveContext()
    }
    
    @objc func updateTrackSlider() {
        guard let player = player else { return }
        let seconds: Int64 = Int64(trackSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
        if player.rate == 0 {
            player.play()
        }
    }
    
    func retrieveAudioPreview() {
        let urlString = track.previewUrl
        guard let url = URL.init(string: urlString!) else { return }
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
    }
    
    func downloadImage() {
        guard let urlString = track.album?.images.first?.url,
              let imageUrl = URL(string: urlString) else { return }
        albumImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil) { (receivedSize, totalSize) in
            
        } completionHandler: { (result) in
            do {
                let _ = try result.get()
            } catch {
                DispatchQueue.main.async {
                    print("Done downloading image")
                }
            }
        }
    }
}
