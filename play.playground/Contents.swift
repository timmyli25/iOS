import UIKit

class CoronaCasesCounty
{
    let countyFips: Int
    let countyName: String
    let countyState: String
    let stateFips: Int
    let casesByDate : [String : Int]
    init(countyFips:Int, countyName:String, countyState:String, stateFips:Int)
    {
        self.countyFips = countyFips
        self.countyName = countyName
        self.countyState = countyState
        self.stateFips = stateFips
        self.casesByDate = [String:Int](minimumCapacity:3200)
    }
}

public class CoronaDataManager
{
    let downloadURL:String = "https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv"
    var countyCases:[CoronaCasesCounty] = []
    public static let sharedInstance = CoronaDataManager()
    
    func parseCoronaData(data: String)
    {
        let rows:[String] = data.components(separatedBy: "\n")
        //self.countyCases.reserveCapacity(rows.count)
        print(self.countyCases.count, self.countyCases.capacity)
        for row in rows[1 ... rows.count - 2]
        {
            //print(row)
            let rowEntries:[String] = row.components(separatedBy: ",")
            let countyFips:Int = Int(rowEntries[0])!
            let stateFips:Int = Int(rowEntries[3])!
            let countyInfo: CoronaCasesCounty = CoronaCasesCounty(countyFips: countyFips, countyName: rowEntries[1], countyState: rowEntries[2], stateFips: stateFips)
           self.countyCases.append(countyInfo)
        }
        print(countyCases.count)
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
}

let client = CoronaDataManager()
client.downloadCoronaData()
print(client.countyCases.count)
