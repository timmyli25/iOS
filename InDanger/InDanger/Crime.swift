import UIKit

struct Crime: Codable{
    let id: String?
    let date: String?
    let primary_type: String?
    let description: String?
    let year: String?
    let latitude: String?
    let longitude: String?
}

class CrimeClient{
    let limit = 1000
    let apptoken = "5SXdw1AGG4VRekJ0bsaBFMfyx"
    func fetchCrime(completion: @escaping ([Crime]?, Error?)->Void){
        let url = URL(string: "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$app_token=\(self.apptoken)&$limit=\(self.limit)")!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.global(qos: .userInitiated).async { completion(nil, error) }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let releases = try decoder.decode([Crime].self, from: data)
                DispatchQueue.global(qos: .userInitiated).async { completion(releases, nil) }

            } catch (let parsingError) {
                DispatchQueue.global(qos: .userInitiated).async { completion(nil, parsingError) }
            }
        }
        task.resume()
    }
}

class CrimeManager{
    var allCrimes: [Crime] = []
    var client :CrimeClient = CrimeClient()
    
    func downloadCrime()->Void{
        client.fetchCrime{ (crime, error)
            in guard let crime = crime, error == nil else {
                print(error!)
                return
            }
            //print(crime)
            print(crime.count)
        }
    }
}
