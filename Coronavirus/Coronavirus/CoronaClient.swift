import UIKit
import MapKit

class CoronaCasesCounty
{
    let countyFips: Int
    let countyName: String
    let countyState: String
    let stateFips: Int
    let lat: Float
    let long : Float
    var annotationsByDate:[String:Annotation] = [String:Annotation]()
    init(countyFips:Int, countyName:String, countyState:String, stateFips:Int, lat: Float, long: Float, counts: [Int?], dates:[String])
    {
        self.countyFips = countyFips
        self.countyName = countyName
        self.countyState = countyState
        self.stateFips = stateFips
        self.lat = lat
        self.long = long
        for N in 0..<dates.count
        {
            let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: NSNumber(value: lat)), longitude: CLLocationDegrees(truncating: NSNumber(value: long)))
            let annotation = Annotation()
            annotation.name = "county"
            annotation.title = countyName
            if (counts[N] != nil)
            {
                annotation.longDescription = "Cases: \(counts[N]!)"
                annotation.caseCount = counts[N]
            } else {
                annotation.longDescription = "Cases: Not Updated"
                annotation.caseCount = counts[N]
            }
            annotation.coordinate = coordinates
            annotationsByDate[dates[N]] = annotation
        }
    }
}

struct countyCoord:Codable
{
    let fips: Int
    let county: String
    let population: Int
    let lat: Float
    let long: Float
}

struct allCoords: Decodable
{
    let coords : [countyCoord]
}

public class CoronaDataManager
{
    let downloadURL:String = "https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv"
    var countyCases:[CoronaCasesCounty] = []
    var didFinishDownload: Bool = false
    var countyCoords:[Int:countyCoord] = [Int:countyCoord]()
    var dateStrings:[String] = [String]()
    public static let sharedInstance = CoronaDataManager()
    func parseCoronaData(data: String)
    {
        let rows:[String] = data.components(separatedBy: "\n")
        self.countyCases.reserveCapacity(rows.count)
        let dateRow:[String] = rows[0].components(separatedBy: ",")
        let dates = dateRow[4 ... dateRow.count - 2].map({String($0)})
        dateStrings = dates
        for row in rows[1 ... rows.count - 2]
        {
            let rowEntries:[String] = row.components(separatedBy: ",")
            let countyFips:Int = Int(rowEntries[0])!
            let stateFips:Int = Int(rowEntries[3])!
            let dateCount = rowEntries[4 ... rowEntries.count - 2].map({Int($0)})
            let countycoord = countyCoords[countyFips]
            if countycoord != nil
            {
                let countyInfo: CoronaCasesCounty = CoronaCasesCounty(countyFips: countyFips, countyName: rowEntries[1], countyState: rowEntries[2], stateFips: stateFips, lat: countycoord!.lat,long: countycoord!.long, counts: dateCount, dates: dates)
                self.countyCases.append(countyInfo)
            }
        }
        didFinishDownload = true
    }
    
    func downloadCoronaData()
    {
        let url = URL(string: self.downloadURL )!

        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL
            {
                if let string = try? String(contentsOf: localURL)
                {
                    self.parseCoronaData(data: string)
                }
            }
        }
        task.resume()
    }
    
    func loadJson() {
        if let url = Bundle.main.url(forResource: "countyDemo", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(allCoords.self, from: data)
                for coord in jsonData.coords
                {
                    self.countyCoords[coord.fips] = coord
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
