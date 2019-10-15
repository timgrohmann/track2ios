//
//  TimetablesAPI.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 15.10.19.
//  Copyright © 2019 Tim Grohmann. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class TimetablesAPI {
    let token: String
    let version: String
    let rootURL: String
    
    init() {
        if let tkn = DBAPISecrets.accessKey, let rurl = DBAPISecrets.timetablesPath {
            self.token = tkn
            self.version = "v1"
            self.rootURL = rurl + self.version
        } else {
            fatalError("DBOpenData not configured")
        }
    }
    
    private func getFromAPI<T>(path: [String], completion: @escaping (Result<T, Error>) -> (), handler: @escaping (AFDataResponse<Data?>) throws -> T) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token),.accept("application/xml")]
        
        AF.request(rootURL + "/" + path.joined(separator: "/"), method: .get, headers: headers)
            .response {
                response in
                let result: Result<T, Error>
                do {
                    let t = try handler(response)
                    result = .success(t)
                } catch {
                    result = .failure(error)
                }
                completion(result)
        }
    }
    
    func getStations(pattern: String, completion: @escaping (Result<[Station], Error>) -> ()) {
        getFromAPI(path: ["station", pattern], completion: completion) {
            response in
            guard let data = response.data else {
                throw DBAPI.APIError.NoData
            }
            let xml = SWXMLHash.parse(data)
            
            let stations = xml["stations"]["station"].all.compactMap {
                let element = $0.element
                if let name = element?.attribute(by: "name")?.text, let stringCode = element?.attribute(by: "eva")?.text, let code = Int(stringCode) {
                    return Station(name: name, id: code)
                }
                return nil
            } as [Station]
            return stations
        }
    }
    
    func getPlan(evaNo: String, date: Date, completion: @escaping (Result<[Stop], Error>) -> ()) {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyMMdd"
        let formattedDate = dayFormatter.string(from: date)
        
        let hourFormatter = dayFormatter
        hourFormatter.dateFormat = "HH"
        let formattedHour = dayFormatter.string(from: date)
        
        getFromAPI(path: ["plan",evaNo,formattedDate,formattedHour], completion: completion) {
            response in
            guard let data = response.data else {
                throw DBAPI.APIError.NoData
            }
            let xml = SWXMLHash.parse(data)
            let xmlStops = xml["timetable"]["s"].all
            
            let stops: [Stop] = xmlStops.compactMap { try? Stop(xml: $0) }
            
            return stops
        }
    }
}
