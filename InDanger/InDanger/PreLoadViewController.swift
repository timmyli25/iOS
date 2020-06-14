//
//  ViewController.swift
//  InDanger
//
//  Created by Timmy Li on 3/12/20.
//  Copyright © 2020 Timmy Li. All rights reserved.
//

import UIKit

class PreLoadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Preload")

    }

    func presentMapViewController(){
        let mainstoryboard = UIStoryboard(name:"Main", bundle: Bundle.main)
        if let mapviewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "mapviewcontroller") as? UIViewController{
            mapviewcontroller.modalPresentationStyle = .fullScreen
            self.present(mapviewcontroller, animated: true, completion: nil)
        }
//        print("seguing")
//        performSegue(withIdentifier: "mapviewsegue", sender: self)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presentMapViewController()
    }



}

