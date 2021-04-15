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
        removeOverlays()
        guard let coordinates = LocationService.instance.currentLocation else { return }
        if parkedCarAnnotiation == nil {
            setupAnnotation(coordinate: coordinates)
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
            directionsButton.isEnabled = true
        } else {
            parkButton.setImage(#imageLiteral(resourceName: "parkCar"), for: .normal)
            parkedCarAnnotiation = nil
            directionsButton.isEnabled = false
            removeOverlays()
            centerMapOnUserLocation(coordinates: coordinates)
        }
    }
    
    @IBAction func getDirectionsTapped(sender: RoundButton) {
        guard let userCoordinates = LocationService.instance.currentLocation,
              let parkedCar = parkedCarAnnotiation else { return }
        
        getDirectionsToCar(userCoordinates: userCoordinates, parkedCarCoordinate: parkedCar.coordinate)
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
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        self.mapView.setRegion(region, animated: true)
    }
    
    func setupAnnotation(coordinate: CLLocationCoordinate2D) {
        parkedCarAnnotiation = ParkingSpot(coordinate: coordinate)
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinates = LocationService.instance.currentLocation,
              let parkedCar = parkedCarAnnotiation else { return }
        getDirectionsToCar(userCoordinates: coordinates, parkedCarCoordinate: parkedCar.coordinate)
        view.setSelected(false, animated: true)
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
        if gesture.state == .ended {
            removeOverlays()
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            setupAnnotation(coordinate: coordinate)
            
            directionsButton.isEnabled = true
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
        }
    }
}

extension ViewController {
    func getDirectionsToCar(userCoordinates: CLLocationCoordinate2D, parkedCarCoordinate: CLLocationCoordinate2D) {
        removeOverlays()
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinates))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: parkedCarCoordinate))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] (response, error) in
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
            
            for step in route.steps {
                print(step.distance)
                print(step.instructions)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let directionsRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        directionsRenderer.strokeColor = .systemBlue
        directionsRenderer.lineWidth = 5
        directionsRenderer.alpha = 0.85
        
        return directionsRenderer
    }
    
    func removeOverlays() {
        self.mapView.overlays.forEach({ self.mapView.removeOverlay($0) })
        //self.mapView.removeAnnotations(mapView.annotations)
    }
}

