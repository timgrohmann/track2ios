//
//  DBAPISecrets.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 11.10.19.
//  Copyright © 2019 Tim Grohmann. All rights reserved.
//

import Foundation

class DBAPISecrets {
    static var accessKey: String? = DBAPISecrets.variable(named: "DB_ACCESS_KEY")
    static var rootPath: String? = DBAPISecrets.variable(named: "DB_ROOT_PATH")
    
    static func variable(named name: String) -> String? {
        return variableFromEnv(named: name) ?? variableFromPlist(named: name)
    }
    
    static func variableFromEnv(named name: String) -> String? {
        let processInfo = ProcessInfo.processInfo
        guard let value = processInfo.environment[name] else {
            return nil
        }
        return value
    }
    
    static func variableFromPlist(named name: String) -> String? {
        if let path = Bundle.main.path(forResource: "DBOpenData.secret", ofType: "plist"),
            let infoDict = NSDictionary(contentsOfFile: path) {
            return infoDict[name] as? String
        }
        return nil
    }
}
