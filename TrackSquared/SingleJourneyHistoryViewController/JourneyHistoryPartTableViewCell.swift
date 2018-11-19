//
//  JourneyHistoryPartTableViewCell.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 19.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class JourneyHistoryPartTableViewCell: UITableViewCell {

    @IBOutlet weak var startStationLabel: UILabel!
    @IBOutlet weak var goalStationLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var goalTimeLabel: UILabel!
    @IBOutlet weak var trainLabel: UILabel!
    
    @IBInspectable var positiveDelayTextColor: UIColor?
    @IBInspectable var negativeOrNoDelayTextColor: UIColor?
    

    func displayPart(part: JouneyPart) {
        if let startEv = part.start, let goalEv = part.goal {
            startStationLabel.text = startEv.station?.name
            goalStationLabel.text = goalEv.station?.name
            
            startTimeLabel.text = startEv.timeRep()
            if startEv.getDelay() > 0 {
                startTimeLabel.textColor = positiveDelayTextColor
            } else {
                startTimeLabel.textColor = negativeOrNoDelayTextColor
            }
            goalTimeLabel.text = goalEv.timeRep()
            if goalEv.getDelay() > 0 {
                goalTimeLabel.textColor = positiveDelayTextColor
            } else {
                goalTimeLabel.textColor = negativeOrNoDelayTextColor
            }
            trainLabel.text = part.train?.stringRepresentation()
        }
    }

}
