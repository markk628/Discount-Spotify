//
//  ArtistController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/8/20.
//

import UIKit
import Spartan

class ArtistController: UIViewController, TrackSubscriber {
    
    var coordinator: TabBarCoordinator!
    var miniPlayer: MiniPlayerController?
    var artist: Artist!
    var tracks: [Track] = []
    var currentTrack: Track?
    lazy var artistId = self.artist.id as! String
        
    let tap = UIGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
    lazy var tracksTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        return tableView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        miniPlayer?.delegate = self
    }
    
    fileprivate func setupViews() {
        let miniPlayer = MiniPlayerController()
        self.view.backgroundColor = .black
        self.title = artist.name
        fetchTracks()
        
        self.view.addSubview(tracksTableView)
        tracksTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        miniPlayer.view.frame = CGRect(x: 0, y: self.view.frame.height - 100, width: self.view.frame.width, height: 64)
        self.addChild(miniPlayer)
        miniPlayer.didMove(toParent: self)
//        self.view.addSubview(containerView)
//        containerView.snp.makeConstraints {
//            $0.left.right.equalToSuperview()
//            $0.bottom.equalToSuperview().offset(-100)
//            $0.height.equalTo(64)
//        }
//        containerView.addSubview(miniPlayer.view)
//        miniPlayer.didMove(toParent: self)
    }
    
    func fetchTracks() {
        NetworkManager.getArtistTopTracks(artistId: artistId) { (result) in
            switch result {
            case .failure(let error):
                self.presentAlert(title: "Error Fetching Tracks", message: error.localizedDescription)
            case .success(let tracks):
                self.tracks = tracks
                DispatchQueue.main.async {
                    self.tracksTableView.reloadData()
                }
            }
        }
    }
    
    @objc func miniPlayerTapped() {
        
    }
}

extension ArtistController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
//            self.coordinator.goToTrackControllerHome(track: track)
        currentTrack = track
        miniPlayer?.configure(track: currentTrack)
    }
}

extension ArtistController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
        DispatchQueue.global().async {
            let track = self.tracks[indexPath.row]
            DispatchQueue.main.async {
                cell.populateViews(track: track, rank: indexPath.row + 1)
                cell.layoutSubviews()
            }
        }
        return cell
    }
}

extension ArtistController: MiniPlayerDelegate {
    func expandTrack(track: Track) {
        guard let maxPlayer = UIViewController() as? MaxPlayerController else {
            assertionFailure("no MaxPlayerController available")
            return
        }
        
        maxPlayer.backingImage = view.makeSnapshot()
        maxPlayer.currentTrack = track
        maxPlayer.sourceView = miniPlayer
        if let tabBar = tabBarController?.tabBar {
            maxPlayer.tabBarImage = tabBar.makeSnapshot()
        }
        present(maxPlayer, animated: false)
    }
}
