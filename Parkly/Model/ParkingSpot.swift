//
//  ParkingSpot.swift
//  Parkly
//
//  Created by Claudia Maciel on 4/13/21.
//

import UIKit
import MapKit

class ParkingSpot: NSObject, MKAnnotation {
    var title: String? = "We Parked Here"
    var subtitle: String? = "Tap for directions"
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
