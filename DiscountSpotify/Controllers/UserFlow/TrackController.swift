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
    var timer: Timer?
    
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
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()
    
    lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.font = systemFont
        label.textColor = .lightCyan
        label.text = track.name
        return label
    }()
    
    lazy var albumNameLabel: UILabel = {
        let label = UILabel()
        let systemFont = UIFont.systemFont(ofSize: 18, weight: .light)
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
    
    lazy var dismissArrowImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "dismiss")?.withTintColor(.fluorescentBlue).withRenderingMode(.alwaysOriginal)
        imageView.image = image
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }

    fileprivate func setupViews() {
        self.view.backgroundColor = .black
        downloadImage()
        self.view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.9)
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.top.equalToSuperview().offset(20)
        }

        [dismissArrowImageView, albumImageView, trackNameLabel, albumNameLabel, trackSlider, playAndFavoriteButtonStackView].forEach {
            mainStackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalToSuperview()
            }
        }
        dismissArrowImageView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalToSuperview().multipliedBy(0.3)
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
    
    func currentTime() -> (current: Double, duration: Double) {
        // Access current item
        if let currentItem = player?.currentItem,
           currentItem.duration >= CMTime.zero {
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds
            return (playhead, duration)
        }
        return (0, 0)
    }
    
    @objc func playButtonPressed() {
        retrieveAudioPreview()
        player?.play()
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateTrackTime), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTrackTime() {
        guard let player = player,
              let item = player.currentItem,
              item.status == .readyToPlay //make sure item is ready to play
        else { return }
        let times = currentTime()
        //update slider
        trackSlider.maximumValue = Float(times.duration)
        trackSlider.value = Float(times.current)
    }
    
    @objc func favoriteButtonPressed() {
//        let newTrack = FavTracks(context: store.mainContext)
//        newTrack.trackCoreData = (track.id as! String)
//        store.saveContext()
        Spartan.saveTracks(trackIds: [track?.id as! String], success: nil, failure: spartanCallbackError)
    }
    
    @objc func updateTrackSlider() {
        guard let player = player else { return }
        let seconds: Int64 = Int64(trackSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
        if player.rate == 0 {
            player.play()
        }
        var count = Float(track.durationMs/1000)
        while count > 0 {
            trackSlider.value = count
            count -= 1
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
