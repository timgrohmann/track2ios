//
//  TimetablesAPITest.swift
//  TrackSquaredTests
//
//  Created by Tim Grohmann on 15.10.19.
//  Copyright © 2019 Tim Grohmann. All rights reserved.
//

import XCTest
@testable import TrackSquared

class TimetablesAPITests: XCTestCase {

    var API: TimetablesAPI = TimetablesAPI()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        API = TimetablesAPI()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStationRMIsMannheim() {
        let exp = XCTestExpectation()
        API.getStations(pattern: "RM") { result in
            switch result {
            case .success(let stations):
                XCTAssertEqual(stations[0].name, "Mannheim Hbf")
            case .failure:
                XCTFail("Error during API call")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
    }

    func testMannheimDepartures() {
        let exp = XCTestExpectation()

        // tests for "Mannheim Hbf" at current time
        API.getPlan(evaNo: "8000244", date: Date()) { result in
            switch result {
            case .success(let stops):
                XCTAssertGreaterThan(stops.count, 0)
                for stop in stops {
                    // every stop has to have an id
                    XCTAssertNotNil(stop.id)
                    // every stop needs to have at least one of .arrival or .departure
                    XCTAssert(stop.arrival != nil || stop.departure != nil)

                    let event = stop.arrival ?? stop.departure!
                    // every stop should be less than an hour away from the current time
                    XCTAssertLessThan(abs(event.timestamp.timeIntervalSince(Date())), 60 * 70)
                }
            case .failure:
                XCTFail("Error during API call")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
    }

    func testFchg() {
        let exp = XCTestExpectation()

        API.getChanges(evaNo: "8000244") { result in
            switch result {
            case .success(let changes):
                XCTAssertGreaterThan(changes.count, 0)
                for change in changes {
                    // every change has to be assoctiated with a stop
                    XCTAssertNotNil(change.stopId)
                }
            case .failure:
                XCTFail("Error during API call")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
    }
}
