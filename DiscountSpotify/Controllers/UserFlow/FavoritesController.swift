//
//  FavoritesController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/1/20.
//

import UIKit
import Spartan
import CoreData
import Kingfisher

class FavoritesController: UIViewController {
    
    var coordinator: TabBarCoordinator!
    var store = CoreDataStack(modelName: "DiscountSpotify")
    var trackIds: [String] = []
    var tracks: [Track] = []
    var offset: Int = 0
    
    var spartanCallbackError: (Error?) -> () {
        get {
            return {[weak self] error in
                if let error = error {
                    self?.presentAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(reloadTableView), for: .valueChanged)
        return refresh
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<FavTracks> = {
        let fetchedRequest: NSFetchRequest<FavTracks> = FavTracks.fetchRequest()
        fetchedRequest.sortDescriptors = []
        let fetchedResultscontroller = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultscontroller.delegate = self
        return fetchedResultscontroller
    }()
    
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
//        if UserDefaults.standard.bool(forKey: "firstTime") == true {
//            fetchFavTracks()
//            UserDefaults.standard.set(false, forKey: "firstTime")
//        } else {
//            fetchFavTracksFromCD()
//        }
        fetchFavTracks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFavTracksFromCD()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        offset = 0
    }
    
    func setupViews() {
        self.createGradientLayer(vc: self)
        self.title = "Favorites"

        self.view.addSubview(tracksTableView)
        tracksTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tracksTableView.addSubview(refreshControl)
    }
    
    func fetchFavTracks() {
        NetworkManager.getFavoriteTracks(offset: offset) { (result) in
            switch result {
            case .failure(let error):
                self.presentAlert(title: "Error Getting Saved Tracks", message: error.localizedDescription)
            case .success(let savedTracks):
                var savedArray: [Track] = []
                savedTracks.forEach {
                    let newTrack = FavTracks(context: self.store.mainContext)
                    newTrack.trackCoreData = ($0.track.id as! String)
                    self.store.saveContext()
                    savedArray.append($0.track)
                }
                self.tracks = savedArray
                self.offset = savedTracks.count - 1
                self.tracksTableView.reloadData()
            }
        }
    }
    
    func fetchFavTracksFromCD() {
        do {
            trackIds.removeAll()
            try fetchedResultsController.performFetch()
            let favTracks = fetchedResultsController.fetchedObjects
            favTracks?.forEach({ (result) in
                trackIds.append(result.trackCoreData ?? "")
            })
            print(trackIds)
            NetworkManager.getCoreDataTracks(ids: trackIds) { (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
//                        self.presentAlert(title: "No Tracks", message: "Add Tracks To Your Favorites")
                        print(error.localizedDescription)
                    }
                case .success(let tracks):
                    self.tracks = tracks
                    DispatchQueue.main.async {
                        self.tracksTableView.reloadData()
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func reloadTableView() {
        fetchFavTracks()
        refreshControl.endRefreshing()
    }
}

extension FavoritesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        coordinator.tabBarController.currentTrack = track
        coordinator.tabBarController.miniPlayerContainerView.configure(track: track)
    }
}

extension FavoritesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            store.mainContext.delete(fetchedResultsController.object(at: indexPath))
            store.saveContext()
            trackIds.remove(at: indexPath.row)
            Spartan.removeSavedTracks(trackIds: [tracks[indexPath.row].id as! String], success: nil, failure: spartanCallbackError)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
        let track = self.tracks[indexPath.row]
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                cell.populateViews(track: track, rank: indexPath.row + 1)
                cell.layoutSubviews()
            }
        }
        return cell
    }
    
}

extension FavoritesController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tracksTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tracks.remove(at: indexPath!.row)
            tracksTableView.deleteRows(at: [indexPath!], with: .left)
        default:
            print("this executable enough for ya?")
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tracksTableView.endUpdates()
    }
}
