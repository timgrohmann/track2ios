//
//  Station.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 27.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation

extension Station {
    class func fromAPI(station input: DBAPI.APIStation) -> Station{
        let s = Station(context: dataController.ctx)
        s.name = input.name
        s.code = ""
        dataController.save()
        return s
    }
}
