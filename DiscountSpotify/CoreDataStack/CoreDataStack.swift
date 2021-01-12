//
//  CoreDataStack.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/10/20.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    
    var count = 0
        
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var fetchedContext: NSFetchRequest<FavTracks> = {
        return FavTracks.fetchRequest()
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}

extension CoreDataStack {
    func saveContext() {
        guard mainContext.hasChanges else { return }
        do {
            count += 1
            try mainContext.save()
            print("saved to CD \(count)")
        } catch let nserror as NSError {
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func fetchPersistentData(completion: @escaping (FetchTrackIdsResult) -> Void) {
        do {
            let allTracks = try mainContext.fetch(fetchedContext)
            completion(.success(allTracks))
        } catch {
            completion(.failure(error))
        }
    }
}

enum FetchTrackIdsResult {
    case success([FavTracks])
    case failure(Error)
}
