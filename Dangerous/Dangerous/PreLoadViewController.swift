import UIKit

class PreLoadViewController: UIViewController {

    @IBOutlet var appTitle: UILabel!
    @IBOutlet var appVersion: UILabel!
    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        appVersion.text = "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
    }

// Activity Spinner https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening

    func presentMapViewController(){
        let mainstoryboard = UIStoryboard(name:"Main", bundle: Bundle.main)
        if let mapviewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "mapviewcontroller") as? MapViewController{
            mapviewcontroller.modalPresentationStyle = .fullScreen
            CrimeManager.sharedInstance.downloadCrime()
            activitySpinner.hidesWhenStopped = true
            activitySpinner.startAnimating()
            while(!CrimeManager.sharedInstance.finishedDownload){
                Thread.sleep(forTimeInterval: 1.0)
            }
            activitySpinner.stopAnimating()
            self.present(mapviewcontroller, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presentMapViewController()
    }
}

