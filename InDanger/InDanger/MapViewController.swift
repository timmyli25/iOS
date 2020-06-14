//
//  MapViewController.swift
//  InDanger
//
//  Created by Timmy Li on 3/14/20.
//  Copyright © 2020 Timmy Li. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userAnnotation: MKPointAnnotation?
    var crimeAnnotations: [MKPointAnnotation] = []
    var crimeManager: CrimeManager = CrimeManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        crimeManager.downloadCrime()
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        if (self.userAnnotation == nil){
            mapView.mapType = MKMapType.standard

            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: locValue, span: span)
            mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = locValue
            annotation.title = "You"
            annotation.subtitle = "Your location."
            self.userAnnotation = annotation
            mapView.addAnnotation(annotation)
        } else {
            self.userAnnotation?.coordinate = locValue
        }

    }
}
