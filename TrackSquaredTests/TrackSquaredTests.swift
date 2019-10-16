//
//  TrackSquaredTests.swift
//  TrackSquaredTests
//
//  Created by Tim Grohmann on 22.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import XCTest
@testable import TrackSquared

class TrackSquaredTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStatoionAPIAccess() {
        let test = DBAPI()
        let expectation = XCTestExpectation(description: "Get stations from API")

        test.getLocations(name: "Mannheim") { stat, error in
            XCTAssert(error == nil)
            XCTAssert(stat.count > 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testDepartureBoardAPIAccess() {
        let test = DBAPI()
        let expectation = XCTestExpectation(description: "Get departures for Mannheim from API")

        let station = DBAPI.APIStation(name: "Mannheim", id: 8000244)
        test.getDepartures(station: station, time: Date()) { deps, error in

            XCTAssert(error == nil)
            XCTAssert(deps.count > 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testDetailsAPIAccess() {
        let test = DBAPI()
        let expectation = XCTestExpectation(description: "Get details for next train from Mannheim from API")

        let station = DBAPI.APIStation(name: "Mannheim", id: 8000244)
        test.getDepartures(station: station, time: Date()) { deps, error in

            XCTAssert(error == nil)
            XCTAssert(deps.count > 0)

            test.getTrainStopDetails(departure: deps[0]) { details, error in
                XCTAssert(error == nil)
                XCTAssert(details.count > 0)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
