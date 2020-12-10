//
//  FavTracks+CoreDataProperties.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 12/10/20.
//
//

import Foundation
import CoreData


extension FavTracks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavTracks> {
        return NSFetchRequest<FavTracks>(entityName: "FavTracks")
    }

    @NSManaged public var trackCoreData: String?

}

extension FavTracks : Identifiable {

}
