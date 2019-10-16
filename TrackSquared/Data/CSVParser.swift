//
//  CSVParser.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 13.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation

class CSVParser {

    func readFile(name: String) -> String {
        if let url = Bundle.main.url(forResource: name, withExtension: ".csv") {
            do {
                return try String(contentsOf: url, encoding: .utf8)
            } catch {
                print(error)
                fatalError("DS100 could not be read")
            }
        } else {
            fatalError("FileManager not avail")
        }
    }

    func loadStationsFromSave() {
        var stations: [Station] = []

        let all = readFile(name: "DS100")
        var split: [String] = []
        all.enumerateLines { line, _ in
            split.append(line)
        }
        split.remove(at: 0)

        for line in split {
            let stationProps = line.split(separator: ";", omittingEmptySubsequences: false)
            let apiId = String(stationProps[0])
            let code = String(stationProps[1])
            let name = String(stationProps[3])
            if code != "" && name != ""{
                let new = dataController.makeStation()
                new.code = code
                new.name = name
                new.api_id = Int64(apiId)!

                stations.append(new)
            }
        }

        dataController.save()

        print("Loaded \(stations.count) stations from DS100")
    }
}
