//
//  ViewController.swift
//  Buttons
//
//  Created by Timmy Li on 2/11/20.
//  Copyright © 2020 Timmy Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func buttonTapped(_ sender: Any) {
        if (sender as AnyObject).title(for: .normal) == "X"{
            (sender as AnyObject).setTitle("A very long title for this button", for:.normal)
        } else {
            (sender as AnyObject).setTitle("X", for:.normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

