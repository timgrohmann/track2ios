//
//  StationTableViewCell.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 12.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    func display(station: Station) {
        stationLabel.text = station.name
        codeLabel.text = station.code
    }
    
    
}
