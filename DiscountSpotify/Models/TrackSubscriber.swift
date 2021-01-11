//
//  TrackSubscriber.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/10/21.
//

import Foundation
import Spartan

protocol  TrackSubscriber: class {
    var currentTrack: Track? { get set }
}
