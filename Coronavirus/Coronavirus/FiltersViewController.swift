//
//  FiltersViewController.swift
//  Coronavirus
//
//  Created by Timmy Li on 4/1/20.
//  Copyright © 2020 Timmy Li. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {

    @IBAction func didPressFindMeButton(_ sender: Any) {
        self.delegate!.locateUser()
    }
    @IBAction func didPressDateStepper(_ sender: Any) {
        dateLabel.text = CoronaDataManager.sharedInstance.dateStrings[Int(dateStepper.value)]
        self.delegate?.selectedDate = CoronaDataManager.sharedInstance.dateStrings[Int(dateStepper.value)]
        self.delegate?.selectedDateIndex = Int(dateStepper.value)
    }
    @IBAction func didPressCountStepper(_ sender: Any) {
        countLabel.text = "\(Int(countStepper.value))"
        self.delegate!.countThreshold = Int(countStepper.value)
    }
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var dateStepper: UIStepper!
    
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var countStepper: UIStepper!
    
    weak var delegate: CountyFilterDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        dateStepper.minimumValue = 0
        dateStepper.maximumValue = Double(CoronaDataManager.sharedInstance.dateStrings.count - 1)
        dateStepper.stepValue = 1
        dateStepper.value = Double(self.delegate!.selectedDateIndex)
        dateLabel.text = CoronaDataManager.sharedInstance.dateStrings[Int(dateStepper.value)]
        
        countStepper.minimumValue = 0
        countStepper.maximumValue = 1000
        countStepper.value = Double(self.delegate!.countThreshold)
        countStepper.stepValue = 10
        countLabel.text = "\(Int(countStepper.value))"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.filterCounty()
    }
}

protocol CountyFilterDelegate: class{
    var selectedDate: String { get set }
    var selectedDateIndex: Int {get set}
    var countThreshold: Int {get set }
    func filterCounty() -> Void
    func locateUser()->Void
}
