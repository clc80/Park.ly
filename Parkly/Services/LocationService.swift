//
//  LocationService.swift
//  Parkly
//
//  Created by Claudia Maciel on 4/12/21.
//

import Foundation
import CoreLocation

protocol CustomUserLocDelegate {
    func userLocationUpdated(location: CLLocation)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    static let instance = LocationService()
    
    var customUserLocDelgate: CustomUserLocDelegate?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = manager.location?.coordinate
        
        if customUserLocDelgate != nil {
            customUserLocDelgate?.userLocationUpdated(location: locations.first!)
        }
    }
}
