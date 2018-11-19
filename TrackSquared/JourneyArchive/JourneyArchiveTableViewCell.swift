//
//  JourneyArchiveTableViewCell.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 18.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class JourneyArchiveTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    func display(journey: Journey) {
        guard let first = journey.parts?.firstObject as? JouneyPart,
            let last = journey.parts?.lastObject as? JouneyPart else {
            return
        }
        dateLabel.text = DateFormatter.localizedString(from: first.start!.time!, dateStyle: .medium, timeStyle: .short)
        startLabel.text = first.start?.station?.name
        goalLabel.text = last.goal?.station?.name
        
        let interval = last.goal!.time!.timeIntervalSince(first.start!.time!)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        durationLabel.text = formatter.string(from: interval)!
    }
}
