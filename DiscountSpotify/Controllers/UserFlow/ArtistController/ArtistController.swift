//
//  ArtistController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/8/20.
//

import UIKit
import Spartan

class ArtistController: UIViewController {
    
    var artist: Artist!
    var tracks: [Track] = []
    lazy var artistId = self.artist.id as! String

    lazy var tracksTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchTracks()
    }
    
    fileprivate func setupViews() {
        self.view.backgroundColor = .systemBackground
        self.title = artist.name
        self.view.addSubview(tracksTableView)
        tracksTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
}

extension ArtistController: UITableViewDelegate {
    
}

extension ArtistController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
        
        let track = tracks[indexPath.row]
        cell.populateViews(track: track, rank: indexPath.row + 1)
        return cell
    }
    
    
}
