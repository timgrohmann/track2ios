//
//  BoardUnboardViewController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 12.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class BoardUnboardViewController: UIViewController {

    @IBOutlet weak var selectStationButton: UIButton!
    @IBOutlet weak var delayDisplayLabel: UILabel!
    @IBOutlet weak var selectTrainButton: UIButton!
    @IBOutlet weak var confirmButton: ButtonDesignable!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var delayStepper: UIStepper!
    
    
    var currentlySelectedStation: Station?
    var currentlySelectedTrain: Train?
    
    let dc = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let part = dc.getUser().currentPart {
            self.title = "Aussteigen"
            selectTrainButton.isEnabled = false
            selectTrainButton.setTitle(part.train?.stringRepresentation() ?? "", for: .normal)
            selectTrainButton.setTitleColor(UIColor.darkGray, for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        let selectStation = StationSelectViewController() {
            station in
            if let s = station {
                self.currentlySelectedStation = s
                self.selectStationButton.setTitle(self.currentlySelectedStation?.name, for: .normal)
            }
        }
        self.modalPresentationStyle = .formSheet
        self.present(selectStation, animated: true, completion: nil)
    }
    
    @IBAction func trainSelectButtonPressed(_ sender: Any) {
        let selectTrain = TrainSelectViewController() {
            train in
            if let train = train {
                self.currentlySelectedTrain = train
                self.selectTrainButton.setTitle(String(format: "%@ %@", Train.typeNameMap[train.type] ?? "", train.number ?? ""), for: .normal)
            }
        }
        self.modalPresentationStyle = .formSheet
        self.present(selectTrain, animated: true, completion: nil)
    }
    
    @IBAction func delayStepperChanged(_ sender: UIStepper) {
        delayDisplayLabel.text = String(format: "%.0f min", sender.value)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        let u = dc.getUser()
        
        if let p = u.currentPart {
            let endEv = TrainEvent(context: managedObjectContext)
            
            endEv.goalOfPart = p
            p.goal = endEv
            
            endEv.scheduledTime = timePicker.date
            endEv.time = timePicker.date.addingTimeInterval(delayStepper.value * 60)
            endEv.station = currentlySelectedStation
            
            u.currentJourney?.addToParts(p)
            p.currentForUser = nil
            p.journey = u.currentJourney
            
            u.currentPart = nil
        } else {
            let newPart = JouneyPart(context: managedObjectContext)
            
            let startEv = TrainEvent(context: managedObjectContext)
            
            startEv.startOfPart = newPart
            newPart.start = startEv
            
            startEv.scheduledTime = timePicker.date
            startEv.time = timePicker.date.addingTimeInterval(delayStepper.value * 60)
            startEv.station = currentlySelectedStation
            
            newPart.train = currentlySelectedTrain
            
            u.currentPart = newPart
            newPart.currentForUser = u
        }
        

        delegate.saveContext()
        
        self.navigationController?.popViewController(animated: true)
    }
    

}
