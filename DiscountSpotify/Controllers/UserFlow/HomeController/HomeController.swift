//
//  HomeController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit
import SnapKit
import Spartan

enum LightOrDarkMode {
    static var whatMode: [CGColor] {
        if UIViewController().traitCollection.userInterfaceStyle == .light {
            return [UIColor.fluorescentBlue.cgColor, UIColor.white.cgColor]
        } else {
            return [UIColor.fluorescentBlue.cgColor, UIColor.black.cgColor]
        }
    }
}

class HomeController: UIViewController {
    
    var coordinator: TabBarCoordinator!
    var artists: [Artist] = []
    var offset: Int = 0
    
//    var filteredTracks: [SimplifiedTrack] = []
    
//    var query: String = ""
    
//    lazy var searchController: UISearchController = {
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.placeholder = "Search"
//        searchController.searchBar.barStyle = .black
//        searchController.obscuresBackgroundDuringPresentation = false
//        return searchController
//    }()
    
    lazy var artistsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
        tableView.register(ArtistCell.self, forCellReuseIdentifier: ArtistCell.identifier)
        return tableView
    }()
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = self.view.bounds
        layer.colors = [UIColor.fluorescentBlue.cgColor, UIColor.systemBackground.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0.5)
        return layer
    }()
    
//    var isSearchBarEmpty: Bool {
//        return searchController.searchBar.text?.isEmpty ?? true
//    }
    
//    var isFiltering: Bool {
//        return searchController.isActive && !isSearchBarEmpty
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMytopArtists()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        offset = 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIApplication.shared.applicationState == .inactive else { return }
        setUpGradientLayerColor()
    }
    
    fileprivate func setupViews() {
        self.view.backgroundColor = .systemBackground
        self.view.layer.addSublayer(gradientLayer)
        self.title = "Your Top Artists"
//        setupSearchController()
        
        self.view.addSubview(artistsTableView)
        artistsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
//    fileprivate func setupSearchController() {
//        navigationItem.searchController = searchController
//        definesPresentationContext = true
//    }
    
    func setUpGradientLayerColor() {
        gradientLayer.colors = LightOrDarkMode.whatMode
    }
    
    func fetchMytopArtists() {
        NetworkManager.getMyTopArtists { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let artists):
                self.artists = artists
                self.offset = self.artists.count - 1
                self.artistsTableView.reloadData()
            }
        }
    }
}

extension HomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = artists[indexPath.row]
        self.coordinator.goToArtistController(artist: artist)
    }
}

extension HomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        artists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath) as! ArtistCell
        DispatchQueue.global(qos: .userInteractive).async {
            let artist = self.artists[indexPath.row]
            DispatchQueue.main.async {
                cell.populateViews(artist: artist, rank: indexPath.row + 1)
                cell.layoutSubviews()
            }
        }
        return cell
    }
}

//extension HomeController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }
//        query = text
//        
//        NetworkManager.searchTracks(query: text) { (result) in
//            switch result {
//            case .failure(let error):
//                self.presentAlert(title: "Error Searching Tracks", message: error.localizedDescription)
//            case .success(let tracks):
//                self.tracks.removeAll()
//                self.tracks.append(contentsOf: tracks)
//                self.songsTableView.reloadData()
//            }
//        }
//
//        if isSearchBarEmpty {
//            tracks.removeAll()
//            songsTableView.reloadData()
//        }
//
//        _ = Spartan.search(query: text, type: .track, success: { (pagingObject: PagingObject<SimplifiedTrack>) in
//            self.tracks.removeAll()
//            self.tracks.append(contentsOf: pagingObject.items)
//            self.songsTableView.reloadData()
//        }, failure: { (error) in
//            print(error)
//        })
//    }
//}
