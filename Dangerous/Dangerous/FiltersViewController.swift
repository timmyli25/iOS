//
//  FiltersViewController.swift
//  Movies
//
//  Created by Timmy Li on 2/18/20.
//  Copyright © 2020 Timmy Li. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var stepperView: UIStepper!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var distanceSegmentControlView: UISegmentedControl!
    
    
    @IBAction func didPressFindMeButton(_ sender: Any) {
        self.delegate!.locateUser()
    }
    
    @IBAction func didPressStepper(_ sender: Any) {
        
        countLabel.text = Int(stepperView.value).description
        self.delegate?.countThreshold = Int(stepperView.value)
    }
    
    @IBAction func distanceSegmentViewChange(_ sender: Any) {
        self.delegate!.distanceThreshold = Double(distanceSegmentControlView.titleForSegment(at: distanceSegmentControlView.selectedSegmentIndex)!)!
        self.delegate!.distanceIndex = distanceSegmentControlView.selectedSegmentIndex
    }
    
    var choices:[String] = ["All: 0"]
    var keys:[String] = ["All"]
    weak var delegate: CrimeFilterDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        var total:Int = 0
        for (key,crimeList) in CrimeManager.sharedInstance.crimeAnnotations{
            let listCount = crimeList.count
            let choiceEntry = "\(key.lowercased()) : \(listCount)"
            total += listCount
            choices.append(choiceEntry)
            keys.append(key)
        }
        choices[0] = "All: \(total)"
        self.pickerView.selectRow(self.delegate!.crimeIndex, inComponent: 0, animated: false)
        stepperView.value = Double(self.delegate!.countThreshold)
        countLabel.text = Int(stepperView.value).description
        distanceSegmentControlView.selectedSegmentIndex = self.delegate!.distanceIndex
    }
}


extension FiltersViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{

        return choices.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        self.view.endEditing(true)
        return choices[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.delegate?.filterCrime(selection: keys[row])
        self.delegate?.crimeIndex = row
    }
}

protocol CrimeFilterDelegate: class{
    var crimeIndex: Int {get set}
    var countThreshold: Int{get set}
    var distanceThreshold: Double{get set}
    var distanceIndex: Int{get set}
    func filterCrime(selection: String) -> Void
    func locateUser()->Void
}
