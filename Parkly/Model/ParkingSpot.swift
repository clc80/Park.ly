//
//  ParkingSpot.swift
//  Parkly
//
//  Created by Claudia Maciel on 4/13/21.
//

import UIKit
import MapKit

class ParkingSpot: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
    }
}
