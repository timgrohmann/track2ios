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
    @IBOutlet weak var viaLabel: MarqueeLabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    
    var train: DBAPI.APITrain?
    var station: DBAPI.APIStation?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viaLabel.type = .continuous
        viaLabel.animationCurve = .easeInOut
        
        trainLabel.text = train?.name
        goalLabel.text = train?.stops.last?.stopName
        viaLabel.text = viaLabelText()
        departureTimeLabel.text = currentStop()?.depTime ?? ""
    }
    
    func displayTrain(train: DBAPI.APITrain, at station: DBAPI.APIStation?) {
        self.train = train
        self.station = station
    }
    
    func viaLabelText() -> String {
        
        guard let currentStationIndex = getCurrentStationIndexInArray() else {
            return ""
        }
        
        var stationsAfterCurrent = train?.stops[currentStationIndex...] ?? []
        stationsAfterCurrent.removeFirst()
        
        return "über: " + stationsAfterCurrent.map { $0.stopName }.joined(separator: ", ")
    }
    
    func currentStop() -> DBAPI.APITrainStopDetail? {
        
        guard let currentStationIndex = getCurrentStationIndexInArray() else {
            return nil
        }
        
        return train?.stops[currentStationIndex]
    }
    
    func getCurrentStationIndexInArray() -> Int? {
        return train?.stops.firstIndex { $0.stopId == station?.id }
    }
    
}
