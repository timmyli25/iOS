
import UIKit
import MapKit
import Foundation

struct Crime: Codable{
    let id: String?
    let date: String?
    let primaryType: String?
    let description: String?
    let year: String?
    let latitude: String?
    let longitude: String?
    let locationDescription: String?
    let ward: String?
}

class CrimeClient{
    let limit = 1000
    // My app token. Will be deleted after grades are submitted.
    let apptoken = "5SXdw1AGG4VRekJ0bsaBFMfyx"
    func fetchCrime(completion: @escaping ([Crime]?, Error?)->Void){
        let url = URL(string: "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$app_token=\(self.apptoken)&$limit=\(self.limit)")!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.global().async { completion(nil, error) }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let releases = try decoder.decode([Crime].self, from: data)
                DispatchQueue.global().async { completion(releases, nil) }
            } catch (let parsingError) {
                DispatchQueue.global().async { completion(nil, parsingError) }
            }
        }
        task.resume()
    }
}

public class CrimeManager{
    var allCrimes: [Crime] = []
    var crimeAnnotations: [String:[Annotation]] = [:]
    var client :CrimeClient = CrimeClient()
    var finishedDownload: Bool = false
    public static let sharedInstance = CrimeManager()
    fileprivate init(){}
    
    func downloadCrime()->Void{
        client.fetchCrime{ (crime, error)
            in guard let crime = crime, error == nil else {
                print(error!)
                return
            }
            self.allCrimes = crime
            self.crimeToAnnotations()
            self.finishedDownload = true
        }
    }
    
    func crimeToAnnotations()->Void{
        for crime in allCrimes{
            if(crime.latitude != nil && crime.longitude != nil){
            let latitude = Double(crime.latitude!)! as NSNumber
                let longitude = Double(crime.longitude!)! as NSNumber
                let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: latitude), longitude: CLLocationDegrees(truncating: longitude))
                let crimeAnnotation = Annotation()
                crimeAnnotation.name = crime.id
                crimeAnnotation.title = crime.description
                crimeAnnotation.longDescription = crime.description!
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                let date = formatter.date(from: crime.date!)
                formatter.dateStyle = .long
                formatter.timeStyle = .medium
                var dateString: String
                if (date != nil){
                    dateString = formatter.string(from: date!)
                } else {
                    dateString = "Unavailable"
                }
                crimeAnnotation.longDescription = "Date: \(dateString)\nLocation: \(crime.locationDescription ?? "")\nCrime Type: \(crime.primaryType ?? "") "
                crimeAnnotation.coordinate = coordinates
                if crimeAnnotations[crime.primaryType!] != nil{
                    crimeAnnotations[crime.primaryType!]?.append(crimeAnnotation)
                } else {
                    crimeAnnotations[crime.primaryType!] = [crimeAnnotation]
                }
            }
        }
    }
}
