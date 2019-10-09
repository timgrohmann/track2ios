//
//  TrainSelectTableViewCell.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 28.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class TrainSelectTableViewCell: UITableViewCell {

    @IBOutlet weak var trainLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    
    func displayTrain(train: DBAPI.APITrain) {
        trainLabel.text = train.name
        goalLabel.text = train.stops.last?.stopName
    }
    
}
