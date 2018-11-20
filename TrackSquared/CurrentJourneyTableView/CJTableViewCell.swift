//
//  CJTableViewCell.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 10.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit

class CJTableViewCell: UITableViewCell {
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var goalTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var trainLabel: UILabel!
    
    @IBInspectable var positiveDelayTextColor: UIColor?
    @IBInspectable var negativeOrNoDelayTextColor: UIColor?
    
    func displayPart(part: JourneyPart) {
        if let startEv = part.start, let goalEv = part.goal {
            start.text = startEv.station?.name
            goal.text = goalEv.station?.name
            
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
    
    func timeRep(of event: TrainEvent) -> String {
        guard let time = event.time, let scheduledTime = event.scheduledTime else {
            return ""
        }
        let delay = event.getDelay()
        if delay != 0 {
            return DateFormatter.localizedString(from: scheduledTime, dateStyle: .none, timeStyle: .short) + String(format: " (%+d min)", delay)
        } else {
            return DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .short)
        }
    }
}
