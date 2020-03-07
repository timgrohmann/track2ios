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
    var currentlySelectedDepartureStop: TimetablesAPI.Stop?

    init(station: Station?, train: Train?, stop: TimetablesAPI.Stop?) {
        self.currentlySelectedStation = station
        self.currentlySelectedTrain = train
        self.currentlySelectedDepartureStop = stop
        super.init(nibName: "BoardUnboardViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.currentlySelectedTrain = nil
        self.currentlySelectedStation = nil
        self.currentlySelectedDepartureStop = nil
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.selectStationButton.sendActions(for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let part = dataController.getUser().currentPart {
            self.title = "Aussteigen"
            currentlySelectedTrain = part.train
            selectTrainButton.isEnabled = false
            selectTrainButton.setTitle(part.train?.stringRepresentation() ?? "", for: .normal)
            selectTrainButton.setTitleColor(UIColor.darkGray, for: .normal)
        }

        let newTitle = currentlySelectedStation?.name ?? "Bahnhof auswählen…"
        self.selectStationButton.setTitle(newTitle, for: .normal)

        self.selectTrainButton.setTitle(currentlySelectedTrain?.stringRepresentation(), for: .normal)

        if let departure = currentlySelectedDepartureStop?.departure {
            self.timePicker.date = departure.timestamp
            self.delayStepper.value = Double(departure.getDelay())
            delayStepperChanged(delayStepper)
        }
    }

    @IBAction func delayStepperChanged(_ sender: UIStepper) {
        delayDisplayLabel.text = String(format: "%.0f min", sender.value)
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        if currentlySelectedTrain == nil || currentlySelectedStation == nil {
            //TODO: Tell user to enter remaining data
            return
        }

        let currentUser = dataController.getUser()

        if let currentPart = currentUser.currentPart {
            // Current part exists, so this is the end of the part
            let endEv = dataController.makeTrainEvent()

            endEv.goalOfPart = currentPart
            currentPart.goal = endEv

            endEv.scheduledTime = timePicker.date
            endEv.time = timePicker.date.addingTimeInterval(delayStepper.value * 60)
            endEv.station = currentlySelectedStation

            currentUser.currentJourney?.addToParts(currentPart)
            currentPart.currentForUser = nil
            currentPart.journey = currentUser.currentJourney

            currentUser.currentPart = nil
        } else {
            // Current part does not yet exist, so this is a new one
            let newPart = dataController.makeJourneyPart()

            let startEv = dataController.makeTrainEvent()

            startEv.startOfPart = newPart
            newPart.start = startEv

            startEv.scheduledTime = timePicker.date
            startEv.time = timePicker.date.addingTimeInterval(delayStepper.value * 60)
            startEv.station = currentlySelectedStation

            newPart.train = currentlySelectedTrain

            currentUser.currentPart = newPart
            newPart.currentForUser = currentUser
        }

        dataController.save()

        self.navigationController?.popToRootViewController(animated: true)
    }

}
