//
//  TrainSelectTableViewCell.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 28.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit
import MarqueeLabel

class TrainSelectTableViewCell: UITableViewCell {

    @IBOutlet weak var trainLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var viaLabel: MarqueeLabel!
    @IBOutlet weak var departureTimeLabel: UILabel!

    var departure: TimetablesAPI.Stop?
    var station: DBAPI.APIStation?

    override func layoutSubviews() {
        super.layoutSubviews()
        viaLabel.type = .continuous
        viaLabel.animationCurve = .easeInOut

        trainLabel.text = departure?.train.getDisplayName()
        goalLabel.text = departure?.departure!.path.last
        viaLabel.text = "über: " + (departure?.departure!.path.joined(separator: ", ") ?? "")

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none

        let minutesFormatter = DateComponentsFormatter()
        minutesFormatter.allowedUnits = [.hour, .minute]
        minutesFormatter.unitsStyle = .abbreviated


        if let depTime = departure?.departure?.timestamp {
            if let changedDepTime = departure?.departure?.change?.timestamp,
                let changeDiff = Optional(depTime.distance(to: changedDepTime)), changeDiff > 0 {
                let changeDiff = depTime.distance(to: changedDepTime)
                departureTimeLabel.text = dateFormatter.string(from: changedDepTime) + " +" + minutesFormatter.string(from: changeDiff)!
                departureTimeLabel.textColor = .red
            } else {
                departureTimeLabel.text = dateFormatter.string(from: depTime)
                departureTimeLabel.textColor = .white
            }
        }


    }

    func displayDeparture(_ departure: TimetablesAPI.Stop, at station: DBAPI.APIStation?) {
        self.departure = departure
        self.station = station
    }
}
