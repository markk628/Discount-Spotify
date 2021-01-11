//
//  MiniPlayerController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/10/21.
//

import UIKit
import Spartan

protocol MiniPlayerDelegate: class {
    func expandTrack(track: Track)
}

class MiniPlayerController: UIViewController, TrackSubscriber {
    
    //MARK: Properties
    var currentTrack: Track?
    weak var delegate: MiniPlayerDelegate?
    
    lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func tapGesture(_ sender: Any) {
        guard let track = currentTrack else {
            return
        }
        
        delegate?.expandTrack(track: track)
    }
}

// MARK: - MaxiPlayerSourceProtocol
extension MiniPlayerController: MaxiPlayerSourceProtocol {
    
    var originatingFrameInWindow: CGRect {
        return view.convert(view.frame, to: nil)
    }
    
    var originatingCoverImageView: UIImageView {
        return albumImageView
    }
}
