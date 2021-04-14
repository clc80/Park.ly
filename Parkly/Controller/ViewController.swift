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
    @IBOutlet weak var parkButton: RoundButton!
    @IBOutlet weak var directionsButton: RoundButton!
    
    var parkedCarAnnotiation: ParkingSpot?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationAuthStatus()
        mapView.delegate = self
        directionsButton.isEnabled = false
        
        setupLongPress()
    }
    
    @IBAction func resetMapCenter(sender: RoundButton) {
        guard let coordinates = LocationService.instance.currentLocation else { return }
        centerMapOnUserLocation(coordinates: coordinates)
    }

    @IBAction func parkButtonTapped(sender: RoundButton) {
        mapView.removeAnnotations(mapView.annotations)
        
        if parkedCarAnnotiation == nil {
            guard let coordinates = LocationService.instance.currentLocation else { return }
            setupAnnotation(coordinate: coordinates)
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
            directionsButton.isEnabled = true
            
        } else {
            parkButton.setImage(#imageLiteral(resourceName: "parkCar"), for: .normal)
            parkedCarAnnotiation = nil
            directionsButton.isEnabled = false
        }
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
    
    func setupAnnotation(coordinate: CLLocationCoordinate2D) {
        parkedCarAnnotiation = ParkingSpot(title: "We parked here", subtitle: "Tap for directions", coordinate: coordinate)
        mapView.addAnnotation(parkedCarAnnotiation!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotations = annotation as? ParkingSpot {
            let id = "pin"
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
            view.animatesDrop = true
            view.pinTintColor = .red
            view.calloutOffset = CGPoint(x: -8, y: -3)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
        return nil
    }
}

extension ViewController: CustomUserLocDelegate {
    func userLocationUpdated(location: CLLocation) {
        centerMapOnUserLocation(coordinates: location.coordinate)
    }
}

extension ViewController {
    func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPress.minimumPressDuration = 0.75
        self.mapView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            setupAnnotation(coordinate: coordinate)
            
            directionsButton.isEnabled = true
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
        }
    }
}

