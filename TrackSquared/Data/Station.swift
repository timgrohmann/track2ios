//
//  Station.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 27.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation

extension Station {
    class func fromAPI(station input: DBAPI.APIStation) -> Station {
        let station = dataController.makeStation()
        station.name = input.name
        station.code = ""
        station.api_id = Int64(input.id)

        //dataController.save()
        return station
    }

    func toAPIStation() -> DBAPI.APIStation {
        return DBAPI.APIStation(name: self.name!, id: Int(self.api_id))
    }

    public override func willSave() {
        if self.inEvents?.count == 0 {
            //dataController.delete(self)
        }
    }
}
