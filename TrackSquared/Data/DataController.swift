//
//  DataController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 12.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let ctx: NSManagedObjectContext
    
    init() {
        ctx = managedObjectContext
    }
    
    func prepare() {
        if getStations().count == 0 {
            print("Loading stations from csv")
            CSVParser().loadStationsFromSave()
        }
        save()
    }
    
    func getStations() -> [Station] {
        let fetch = NSFetchRequest<Station>(entityName: "Station")
        return executeFetch(fetch: fetch)
    }
    
    func searchStations(search: String) -> [Station] {
        let fetch = NSFetchRequest<Station>(entityName: "Station")
        fetch.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR code CONTAINS[c] %@", search, search)
        var stations = executeFetch(fetch: fetch)
        stations.sort() {
            s1, s2 in
            let cmp = s1.code!.compare(s2.code!)
            return search.lowercased() == s1.code!.lowercased() || s1.code!.count < s2.code!.count || s1.code!.count ==  s2.code!.count && cmp == .orderedAscending
        }
        return stations
    }
    
    func getStation(name: String) -> Station? {
        let fetch = NSFetchRequest<Station>(entityName: "Station")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        var stations = executeFetch(fetch: fetch)
        if stations.count > 0 {
            return stations[0]
        }
        return nil
    }
    
    func getStation(code: String) -> Station? {
        let fetch = NSFetchRequest<Station>(entityName: "Station")
        fetch.predicate = NSPredicate(format: "code == %@", code)
        var stations = executeFetch(fetch: fetch)
        if stations.count > 0 {
            return stations[0]
        }
        return nil
    }
    
    func getTrain(number: String, trainType: Train.Types) -> Train? {
        let fetch = NSFetchRequest<Train>(entityName: "Train")
        fetch.predicate = NSPredicate(format: "number == %@ AND raw_type == %d", number, trainType.rawValue)
        var trains = executeFetch(fetch: fetch)
        if trains.count > 0 {
            return trains[0]
        }
        return nil
    }
    
    func getUser() -> User {
        let fetch = NSFetchRequest<User>(entityName: "User")
        return executeFetch(fetch: fetch)[0]
    }
    
    func executeFetch<T>(fetch: NSFetchRequest<T>) -> [T] {
        do {
            return try managedObjectContext.fetch(fetch)
        } catch {
            fatalError("User could not be fetched/created: \(error)")
            //return []
        }
    }
    
    func save() {
        delegate.saveContext()
    }
    
}
