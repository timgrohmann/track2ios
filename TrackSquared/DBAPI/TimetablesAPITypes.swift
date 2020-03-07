//
//  TimetablesAPIDataTypes.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 15.10.19.
//  Copyright © 2019 Tim Grohmann. All rights reserved.
//

import Foundation
import SWXMLHash

extension TimetablesAPI {
    struct Station {
        var name: String
        var id: Int
    }

    struct Stop {
        let id: String
        let train: TrainRef
        var arrival: StopEvent?
        var departure: StopEvent?

        init(xml: XMLIndexer) throws {
            if let element = xml.element,
                let id = element.attribute(by: "id")?.text {
                self.id = id
            } else {
                throw APIError.malformedXML
            }
            self.train = try TrainRef(xml: xml["tl"][0])
            self.arrival = try? StopEvent(xml: xml["ar"][0])
            self.departure = try? StopEvent(xml: xml["dp"][0])
        }
    }

    struct TrainRef {
        // swiftlint:disable:next identifier_name
        let f, t, o, c, n: String?

        init(xml: XMLIndexer) throws {
            guard let element = xml.element else { throw APIError.malformedXML }
            self.f = element.attribute(by: "f")?.text
            self.t = element.attribute(by: "t")?.text
            self.o = element.attribute(by: "o")?.text
            self.c = element.attribute(by: "c")?.text
            self.n = element.attribute(by: "n")?.text
        }

        func getDisplayName() -> String {
            return "\(c ?? "?") \(n ?? "?")"
        }
    }

    struct StopEvent {
        let timestamp: Date
        let plattform: String?
        let line: String?
        let path: [String]

        var change: StopChangeEvent?

        static var timestampFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyMMddHHmm"
            return formatter
        }

        init(xml: XMLIndexer) throws {
            guard let element = xml.element else { throw APIError.malformedXML }
            if let dateString = element.attribute(by: "pt")?.text,
                let date = StopEvent.timestampFormatter.date(from: dateString) {
                self.timestamp = date
            } else {
                throw APIError.malformedXML
            }
            self.plattform = element.attribute(by: "pp")?.text
            self.line = element.attribute(by: "l")?.text
            self.path = element.attribute(by: "ppth")?.text.split(separator: "|").map {String($0)} ?? []
        }

        /**
         * Returns the number of minutes of delay for this StopEvent.
         */
        func getDelay() -> Int {
            if let changeTimestamp = self.change?.timestamp {
                let diff = changeTimestamp.timeIntervalSince(self.timestamp)
                return Int(diff / 60.0)
            }
            return 0
        }
    }

    struct StopChange {
        let stopId: String

        let arrival: StopChangeEvent?
        let departure: StopChangeEvent?

        init(xml: XMLIndexer) throws {
            let element = try xml.element.unwrap(or: APIError.malformedXML)
            self.stopId = try (element.attribute(by: "id")?.text).unwrap(or: APIError.malformedXML)

            if xml["ar"].element != nil {
                self.arrival = try? StopChangeEvent(xml: xml["ar"])
            } else {
                self.arrival = nil
            }

            if xml["dp"].element != nil {
               self.departure = try? StopChangeEvent(xml: xml["dp"])
            } else {
                self.departure = nil
            }
        }
    }

    struct StopChangeEvent {
        let timestamp: Date?
        let plattform: String?

        init(xml: XMLIndexer) throws {
            guard let element = xml.element else { throw APIError.malformedXML }
            if let dateString = element.attribute(by: "ct")?.text,
                let date = StopEvent.timestampFormatter.date(from: dateString) {
                self.timestamp = date
            } else {
                self.timestamp = nil
            }
            self.plattform = element.attribute(by: "cp")?.text
        }
    }
}
