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
        let arrival: StopEvent?
        let departure: StopEvent?
        
        init(xml: XMLIndexer) throws {
            if let element = xml.element,
                let id = element.attribute(by: "id")?.text {
                self.id = id
            } else {
                throw APIError.MalformedXML
            }
            self.train = try TrainRef(xml: xml["tl"][0])
            self.arrival = try? StopEvent(xml: xml["ar"][0])
            self.departure = try? StopEvent(xml: xml["dp"][0])
        }
    }
    
    struct TrainRef {
        let f, t, o, c, n: String?
        
        init(xml: XMLIndexer) throws {
            guard let element = xml.element else { throw APIError.MalformedXML }
            self.f = element.attribute(by: "f")?.text
            self.t = element.attribute(by: "t")?.text
            self.o = element.attribute(by: "o")?.text
            self.c = element.attribute(by: "c")?.text
            self.n = element.attribute(by: "n")?.text
        }
    }
    
    struct StopEvent {
        let timestamp: Date
        let plattform: String?
        let line: String?
        let path: [String]
        
        static var timestampFormatter: DateFormatter {
            let f = DateFormatter()
            f.dateFormat = "yyMMddHHmm"
            return f
        }
        
        init(xml: XMLIndexer) throws {
            guard let element = xml.element else { throw APIError.MalformedXML }
            if let dateString = element.attribute(by: "pt")?.text,
                let date = StopEvent.timestampFormatter.date(from: dateString) {
                self.timestamp = date
            } else {
                throw APIError.MalformedXML
            }
            self.plattform = element.attribute(by: "pp")?.text
            self.line = element.attribute(by: "l")?.text
            self.path = element.attribute(by: "ppth")?.text.split(separator: "|").map {String($0)} ?? []
        }
    }
}
