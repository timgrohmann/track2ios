//
//  DBAPI.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 22.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation

class DBAPI {
    let token: String
    let version: String
    let rootURL: String

    init() {
        if let tkn = DBAPISecrets.accessKey, let rurl = DBAPISecrets.rootPath {
            self.token = tkn
            self.version = "v1"
            self.rootURL = rurl
        } else {
            fatalError("DBOpenData not configured")
        }
    }

    private func execute(endpoint: [String], params: [String: String] = [:], callback: @escaping (Data?, APIError?) -> Void) {
        var endpoint = endpoint
        endpoint.insert(self.version, at: 0)
        endpoint = endpoint.map {$0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!}
        let urlString = rootURL.appending(endpoint.joined(separator: "/"))
        guard var url = URLComponents(string: urlString) else {
            callback(nil, .invalidURL)
            return
        }

        url.queryItems = params.map {URLQueryItem(name: $0.key, value: $0.value)}

        var req = URLRequest(url: url.url!)
        req.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: req) { data, _, error in
            if error != nil || data == nil {
                callback(nil, .dataTaskError)
                return
            }
            guard let data = data else {
                callback(nil, .noData)
                return
            }

            callback(data, nil)
        }
        task.resume()
    }

    private func getDecodableArray<T: Decodable>(endpoint: [String], params: [String: String] = [:], callback: @escaping ([T], APIError?) -> Void) {
        execute(endpoint: endpoint, params: params) { data, err in
            if let error = err {
                callback([], error)
                return
            }
            do {
                let decodedTs: [T] = try JSONDecoder().decode([T].self, from: data!)
                callback(decodedTs, nil)
            } catch {
                print(String(data: data!, encoding: .utf8) as Any)
                print(endpoint)
                print(error)
                callback([], .jsonError)
            }
        }
    }

    func getLocations(name: String, callback: @escaping ([DBAPI.APIStation], APIError?) -> Void) {
        getDecodableArray(endpoint: ["location", name], callback: callback)
    }

    func getDepartures(station: APIStation, time: Date, callback: @escaping ([DBAPI.APIDeparture], APIError?) -> Void) {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions.remove(.withTimeZone)
        let formatted = formatter.string(from: time)

        getDecodableArray(endpoint: ["departureBoard", String(station.id)], params: ["date": formatted], callback: callback)
    }

    func getTrainStopDetails(departure: APIDeparture, callback: @escaping ([DBAPI.APITrainStopDetail], APIError?) -> Void) {
        getDecodableArray(endpoint: ["journeyDetails", String(departure.detailsId)], callback: callback)
    }

    enum APIError: Error {
        case invalidURL, dataTaskError, noData, jsonError
    }
}
