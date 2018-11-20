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
        
        for s in split {
            let stationProps = s.split(separator: ";", omittingEmptySubsequences: false)
            let code = String(stationProps[1])
            let name = String(stationProps[3])
            if code != "" && name != ""{
                let new = DataController().makeStation()
                new.code = code
                new.name = name
                stations.append(new)
            }
        }
    }
}