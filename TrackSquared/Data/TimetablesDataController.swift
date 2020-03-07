//
//  TimetablesDataController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 02.02.20.
//  Copyright © 2020 Tim Grohmann. All rights reserved.
//

import Foundation

class TimetablesDataController {
    let timetablesAPI = TimetablesAPI()

    var cachedDepartures: Dictionary<String, Dictionary<String, TimetablesAPI.Stop>> = Dictionary()
    var cachedChanges: Dictionary<String, Dictionary<String, TimetablesAPI.StopChange>> = Dictionary()


    func getPlannedDepartures(for station: String, offset: Int, completion: @escaping ([TimetablesAPI.Stop]) -> Void) {
        timetablesAPI.getPlan(evaNo: station, date: Date().addingTimeInterval(60.0 * 60.0 * Double(offset))) { result in
            switch result {
            case .success(let stops):
                let departures = stops.filter { $0.departure != nil }
                if self.cachedDepartures[station] == nil {
                    self.cachedDepartures[station] = Dictionary()
                }
                for departure in departures {
                    self.cachedDepartures[station]![departure.id] = departure
                }
                completion(departures)
            case .failure:
                completion([])
            }
        }
    }

    func getRealTimeDepartures(for station: String, offset: Int, completion: @escaping ([TimetablesAPI.Stop]) -> Void) {
        getPlannedDepartures(for: station, offset: offset) { _ in
            self.timetablesAPI.getChanges(evaNo: station) { result in
                switch result {
                case .success(let changes):
                    for change in changes {
                        self.cachedDepartures[station]![change.stopId]?.departure?.change = change.departure
                    }
                    completion(Array(self.cachedDepartures[station]!.values))
                case .failure(_):
                    completion([])
                }
            }
        }
    }
}
