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
    
    func displayPart(t1: TrainEvent, t2: TrainEvent) {
        start.text = t1.station?.name
        goal.text = t2.station?.name
    }
}
