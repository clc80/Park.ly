//
//  ViewController.swift
//  Parkly
//
//  Created by Claudia Maciel on 4/12/21.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationAuthStatus()
        mapView.delegate = self
    }


}

extension ViewController: MKMapViewDelegate {
    func checkLocationAuthStatus() {
        if LocationService.instance.locationManager.authorizationStatus == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
            LocationService.instance.customUserLocDelgate = self
        } else {
            LocationService.instance.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnUserLocation(coordinates: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
    }
}

extension ViewController: CustomUserLocDelegate {
    func userLocationUpdated(location: CLLocation) {
        centerMapOnUserLocation(coordinates: location.coordinate)
    }
    
    
}

