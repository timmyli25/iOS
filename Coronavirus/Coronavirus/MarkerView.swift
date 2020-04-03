import UIKit
import MapKit

class MarkerView: MKMarkerAnnotationView
{
    var name:String?
    var longDescription: String?
    override var annotation: MKAnnotation?
    {
        willSet
        {
            if((newValue) != nil)
            {
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.font = detailLabel.font.withSize(12)
                let newAnnotation = newValue as! Annotation
                detailLabel.text = newAnnotation.longDescription
                detailCalloutAccessoryView = detailLabel
            }
        }
    }
}

class Annotation:MKPointAnnotation
{
    var name:String?
    var longDescription: String?
    var caseCount: Int?
    var location: CLLocation
    {
        get
        {
            return CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        }
    }
}

