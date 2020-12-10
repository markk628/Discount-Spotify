//
//  ArtistCell.swift
//  MusicApp
//
//  Created by Mondale on 9/30/20.
//  Copyright © 2020 Mondale. All rights reserved.
//

import UIKit
import Spartan

class TrackCell: UITableViewCell {

    static let identifier: String = "TrackTableViewCell"
    var track: Track!
    
    lazy var mainStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var trackRankLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .electricBlue
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        mainStackView.addArrangedSubview(trackRankLabel)
        trackRankLabel.snp.makeConstraints {
            $0.width.height.equalTo(25)
        }
        
        mainStackView.addArrangedSubview(albumImageView)
        albumImageView.snp.makeConstraints {
            $0.height.width.equalTo(self.contentView.snp.height).multipliedBy(0.8)
        }

        mainStackView.addArrangedSubview(trackNameLabel)
        trackNameLabel.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.lessThanOrEqualToSuperview()
        }
    }
    
    func populateViews(track: Track, rank: Int) {
        self.track = track
        trackRankLabel.text = "\(rank)"
        trackNameLabel.text = track.name
        
        guard let urlString = track.album?.images.first?.url,
              let imageUrl = URL(string: urlString) else { return }
        albumImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil) { (receivedSize, totalSize) in
            
        } completionHandler: { (result) in
            do {
                let _ = try result.get() //value
            } catch {
                DispatchQueue.main.async {
                    print("Done downloading image")
                }
            }
        }

    }
}
