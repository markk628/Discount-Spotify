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
//    var savedTracks: [SavedTrack] = []
    var tracks: [Track] = []
    var offset: Int = 0
    
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
        if UserDefaults.standard.bool(forKey: "firstTime") == true {
            fetchFavTracks()
            UserDefaults.standard.set(false, forKey: "firstTime")
        } else {
            fetchFavTracksFromCD()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        fetchFavTracks()
        fetchFavTracksFromCD()
//        self.tracksTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        offset = 0
    }
    
    func setupViews() {
        self.createGradientLayer(vc: self)
        self.title = "Favorites"
//        fetchFavTracks()

        self.view.addSubview(tracksTableView)
        tracksTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
                    print($0.track.name)
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
//            trackIds.removeAll()
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
}

extension FavoritesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        self.coordinator.goToTrackControllerFavorite(track: track)
    }
}

extension FavoritesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
//        return sectionInfo.numberOfObjects
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
        case .insert:
//            tracksTableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .delete:
            tracksTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
//            let cell = tracksTableView.cellForRow(at: indexPath!) as! TrackCell
//            configureCell(cell: cell, for: indexPath!)
            break
        case .move:
            tracksTableView.deleteRows(at: [indexPath!], with: .automatic)
            tracksTableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tracksTableView.endUpdates()
    }
}
