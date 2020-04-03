//
//  MapViewController.swift
//  Coronavirus
//
//  Created by Timmy Li on 3/31/20.
//  Copyright © 2020 Timmy Li. All rights reserved.
//

import UIKit
import MapKit
import StoreKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userAnnotation: Annotation?
    let userNotificationCenter = UNUserNotificationCenter.current()
    var countThreshold: Int = 100
    var selectedDate: String = ""
    var selectedDateIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
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
        
        CoronaDataManager.sharedInstance.loadJson()
        CoronaDataManager.sharedInstance.downloadCoronaData()
        while(!CoronaDataManager.sharedInstance.didFinishDownload)
        {
            sleep(1)
        }
        self.selectedDate = CoronaDataManager.sharedInstance.dateStrings.last!
        self.selectedDateIndex = CoronaDataManager.sharedInstance.dateStrings.count - 1
        filterCounty()
    }
}

extension MapViewController: CLLocationManagerDelegate{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        if (self.userAnnotation == nil){
            mapView.mapType = MKMapType.standard
            let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            let region = MKCoordinateRegion(center: locValue, span: span)
            mapView.setRegion(region, animated: true)
            let annotation = Annotation()
            annotation.name = "User"
            annotation.coordinate = locValue
            annotation.title = "You"
            annotation.longDescription = "This is where you are."
            self.userAnnotation = annotation
            mapView.addAnnotation(annotation)
        } else {
            self.userAnnotation?.coordinate = locValue
        }
    }
}

extension MapViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        guard let annotation = annotation as? Annotation else {return nil}
        if annotation.name == "county"
        {
            var view: MarkerView
            let identifier = "County"
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MarkerView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MarkerView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.clusteringIdentifier = "county"
                view.glyphImage = UIImage(named: "virus.png")
                view.displayPriority = .defaultHigh
            }
            return view
        } else if annotation.name == "User"{
            var view: MarkerView
            let identifier = "User"
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MarkerView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MarkerView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.markerTintColor = .systemBlue
                view.glyphImage = UIImage(systemName: "star.fill")
                view.displayPriority = .defaultHigh
                view.clusteringIdentifier = nil
            }
            return view
        }
        return nil
    }
}

extension MapViewController: CountyFilterDelegate
{
    func filterCounty() {
        let annotationsToRemove = mapView.annotations.filter { $0.title != "You" }
        mapView.removeAnnotations(annotationsToRemove)
        for county in CoronaDataManager.sharedInstance.countyCases
        {
            let count = county.annotationsByDate[self.selectedDate]!.caseCount
            if count == nil || county.annotationsByDate[self.selectedDate]!.caseCount! > self.countThreshold{
                self.mapView.addAnnotation(county.annotationsByDate[self.selectedDate]!)
            }
        }
    }
    
    func locateUser() {
        if let coor = self.userAnnotation?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
}

extension MapViewController: UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle{
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.preferredContentSize = CGSize(width: 300, height: 150)
        if let presentationController = segue.destination.popoverPresentationController {
            presentationController.delegate = self
            let receiver = segue.destination as! FiltersViewController
            receiver.delegate = self
        }
    }
}
