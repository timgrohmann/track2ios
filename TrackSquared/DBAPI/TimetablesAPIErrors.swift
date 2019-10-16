//
//  TimetablesAPIErrors.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 15.10.19.
//  Copyright © 2019 Tim Grohmann. All rights reserved.
//

import Foundation

extension TimetablesAPI {
    enum APIError: Error {
        case malformedXML
    }
}
