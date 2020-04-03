import UIKit
import MapKit
import StoreKit
import CoreLocation

class MapViewController: UIViewController{

    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userAnnotation: Annotation?
    var crimeAnnotations: [MKPointAnnotation] = []
    var choiceIndex = 0
    var distanceThreshold:Double = 800.0
    var distanceIndex: Int = 4
    var countThreshold:Int = 8
    var notificationCount:Int = 0
    let userNotificationCenter = UNUserNotificationCenter.current()
    var lastNotificationTime:Date?
    
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
        self.filterCrime(selection: "All")
        self.userNotificationCenter.delegate = self
        self.requestNotificationAuthorization()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.preferredContentSize = CGSize(width: 300, height: 300)
        if let presentationController = segue.destination.popoverPresentationController { 
            presentationController.delegate = self
            let receiver = segue.destination as! FiltersViewController
            receiver.delegate = self
        }
    }
}

extension MapViewController: UNUserNotificationCenterDelegate{
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
// Sending Notifications
// https://programmingwithswift.com/how-to-send-local-notification-with-swift-5/
    func sendNotification(count: Int) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Danger!"
        notificationContent.body = "You are near \(count) recent crimes!"
        notificationContent.badge = NSNumber(value: 3)
        if let url = Bundle.main.url(forResource: "warning",
                                    withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "warning",
                                                            url: url,
                                                            options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "notificationID\(self.notificationCount)",
                                            content: notificationContent,
                                            trigger: trigger)
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        self.notificationCount += 1
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension MapViewController: CLLocationManagerDelegate{
    // Location Manager Example:
    // https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        if (self.userAnnotation == nil){
            mapView.mapType = MKMapType.standard
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
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
        let currentTime = Date()
        let previousTime = self.lastNotificationTime
        // Cap notifications to one every two minutes.
        if (previousTime == nil) || currentTime.timeIntervalSince(previousTime!) > 120.0{
            let count = countNearbyCrime()
            if count >= self.countThreshold{
                sendNotification(count: count)
            }
            self.lastNotificationTime = currentTime
        }
    }
    
    func countNearbyCrime()->Int{
        var count:Int = 0
        for case let annotation as Annotation in mapView.annotations {
            if (annotation.name != "User"){
                let dist: CLLocationDistance = self.userAnnotation!.location.distance(from: annotation.location)
                if dist < self.distanceThreshold{
                    count += 1
                }
            }
        }
        return count
    }
}

extension MapViewController: UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle{
        return .none
    }
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        guard let annotation = annotation as? Annotation else {return nil}
        
        var view: MarkerView
        if(annotation.name! == "User"){
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
        } else {
            let identifier = "Crime"
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MarkerView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MarkerView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.glyphImage = UIImage(named: "fire.png")
                view.clusteringIdentifier = "Crime"
                view.displayPriority = .defaultLow
            }
        }
    return view
    }
}

extension MapViewController: CrimeFilterDelegate{
    var crimeIndex: Int {
        get {
            return self.choiceIndex
        }
        set {
            self.choiceIndex = newValue
        }
    }
    func filterCrime(selection: String)->Void{
        let annotationsToRemove = mapView.annotations.filter { $0.title != "You" }
        mapView.removeAnnotations(annotationsToRemove)
        if selection == "All"{
            for (_,crimeList) in CrimeManager.sharedInstance.crimeAnnotations{
                for crime in crimeList{
                    mapView.addAnnotation(crime)
                }
            }
        } else {
            for crime in CrimeManager.sharedInstance.crimeAnnotations[selection]!{
                mapView.addAnnotation(crime)
            }
        }
    }
    
    func locateUser() {
        if let coor = self.userAnnotation?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
}
