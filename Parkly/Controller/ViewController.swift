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
        } else {
            LocationService.instance.locationManager.requestWhenInUseAuthorization()
        }
    }
}

