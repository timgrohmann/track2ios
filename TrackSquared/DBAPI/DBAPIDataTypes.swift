//
//  DBAPIDataTypes.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 26.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation

extension DBAPI {
    struct APIStation: Decodable {
        var name: String
        var id: Int
    }
    
    struct APIDeparture: Decodable {
        var name: String
        var type: String? //Apparently some departures don't have types associated with them - DBOpenData has been contacted
        var dateTime: String
        var track: String?
        var detailsId: String
    }
    
    struct APITrainStopDetail: Decodable {
        var stopId: Int
        var stopName: String
        var arrTime: String?
        var depTime: String?
        var train: String
        var type: String
        var `operator`: String
    }
    
    class APITrain {
        var stops: [APITrainStopDetail]
        lazy var name: String? = {
            if stops.count > 0 {
                return stops[0].train
            }
            return nil
        }()
        
        init(stops: [APITrainStopDetail]) {
            self.stops = stops
        }
    }
}
