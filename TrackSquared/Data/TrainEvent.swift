//
//  TrainEvent.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 17.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation

extension TrainEvent {
    
    /**
     * The number of minutes of delay for this event.
     */
    func getDelay() -> Int {
        if let time = self.time, let scheduledTime = self.scheduledTime {
            return Int(time.timeIntervalSince(scheduledTime) / 60)
        } else {
            return 0
        }
    }
    
    func timeRep() -> String {
        guard let time = self.time, let scheduledTime = self.scheduledTime else {
            return ""
        }
        let delay = self.getDelay()
        if delay != 0 {
            return DateFormatter.localizedString(from: scheduledTime, dateStyle: .none, timeStyle: .short) + String(format: " (%+d min)", delay)
        } else {
            return DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .short)
        }
    }
}
