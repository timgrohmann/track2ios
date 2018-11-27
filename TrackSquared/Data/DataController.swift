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
    let api = DBAPI()
    
    init(ctx: NSManagedObjectContext) {
        self.ctx = ctx
    }
    
    func prepare() {
        if getStations().count == 0 {
            print("Loading stations from csv")
            CSVParser().loadStationsFromSave()
        }
        
        let fetch = NSFetchRequest<User>(entityName: "User")
        if executeFetch(fetch: fetch).count == 0 {
            let u = User(context: ctx)
            u.currentJourney = makeJourney()
        }
        save()
    }
    
    /**
     * List all currently known stations.
     */
    func getStations() -> [Station] {
        let fetch = NSFetchRequest<Station>(entityName: "Station")
        return executeFetch(fetch: fetch)
    }
    
    func makeStation() -> Station {
        return Station(context: ctx)
    }
    
    /**
     Search known stations.
     - parameters:
        - search: The search term to be used, either station code or name, case insensitive.
     - returns:
        Array of stations that were found
     */
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
    
    /**
     Search one station by name.
     - parameters:
        - name: The exact name to be searched for, case sensitive.
     - returns:
        A station if found, nil otherwise.
     */
    func getStation(name: String) -> Station? {
        let fetch = NSFetchRequest<Station>(entityName: "Station")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        var stations = executeFetch(fetch: fetch)
        if stations.count > 0 {
            return stations[0]
        }
        return nil
    }
    
    /**
     Search one station by DS100 code.
     - parameters:
        - code: The exact code to be searched for, case sensitive (must be uppercased).
     - returns:
        A station if found, nil otherwise.
     */
    func getStation(code: String) -> Station? {
        let fetch = NSFetchRequest<Station>(entityName: "Station")
        fetch.predicate = NSPredicate(format: "code == %@", code)
        var stations = executeFetch(fetch: fetch)
        if stations.count > 0 {
            return stations[0]
        }
        return nil
    }
    
    /**
     Search one train.
     - parameters:
        - number: Train number to match.
        - trainType: Type to match.
     - returns:
        A train if found, nil otherwise.
     */
    func getTrain(number: String, trainType: Train.Types) -> Train? {
        let fetch = NSFetchRequest<Train>(entityName: "Train")
        fetch.predicate = NSPredicate(format: "number == %@ AND raw_type == %d", number, trainType.rawValue)
        var trains = executeFetch(fetch: fetch)
        if trains.count > 0 {
            return trains[0]
        }
        return nil
    }
    
    func makeTrain() -> Train {
        return Train(context: ctx)
    }
    
    func makeTrainEvent() -> TrainEvent {
        return TrainEvent(context: ctx)
    }
    
    func getJourneys() -> [Journey] {
        let fetch = NSFetchRequest<Journey>(entityName: "Journey")
        return executeFetch(fetch: fetch)
    }
    
    func makeJourney() -> Journey {
        return Journey(context: ctx)
    }
    
    func makeJourneyPart() -> JourneyPart {
        return JourneyPart(context: ctx)
    }
    
    /**
     The current User object.
     */
    func getUser() -> User {
        let fetch = NSFetchRequest<User>(entityName: "User")
        return executeFetch(fetch: fetch)[0]
    }
    
    /**
     Executes a fetch request and returns an array of results.
     May cause fatal error for ill-formatted requests.
     - parameters:
        - fetch: Fetch request which will be executed.
     */
    private func executeFetch<T>(fetch: NSFetchRequest<T>) -> [T] {
        do {
            return try ctx.fetch(fetch)
        } catch {
            fatalError("User could not be fetched/created: \(error)")
            //return []
        }
    }
    
    /**
     Saves current context.
     */
    func save() {
        delegate.saveContext()
    }
    
    func delete(_ obj: NSManagedObject) {
        ctx.delete(obj)
    }
    
}
