//
//  PreLoadViewController.swift
//  Coronavirus
//
//  Created by Timmy Li on 4/1/20.
//  Copyright © 2020 Timmy Li. All rights reserved.
//

import UIKit

class PreLoadViewController: UIViewController {
    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func presentMapViewController(){
        let mainstoryboard = UIStoryboard(name:"Main", bundle: Bundle.main)
        if let mapviewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "mapviewcontroller") as? MapViewController{
            mapviewcontroller.modalPresentationStyle = .fullScreen
            CoronaDataManager.sharedInstance.loadJson()
            CoronaDataManager.sharedInstance.downloadCoronaData()
            activitySpinner.hidesWhenStopped = true
            activitySpinner.startAnimating()
            while(!CoronaDataManager.sharedInstance.didFinishDownload){
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
