//
//  Train.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 14.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import Foundation

extension Train {
    enum Types: Int16 {
        case ICE = 1, IC = 2, RE = 3, RB = 4, S = 5, NE = 6, X = 7
    }
    
    struct NameDesriptor {
        let type: String
        let number: String
    }
    
    static let typeMap: [String:Types] = ["ICE":.ICE,"IC":.IC,"RE":.RE,"RB":.RB,"S":.S]
    static let typeNameMap: [Types:String] = [.ICE:"ICE",.IC:"IC",.RE:"RE",.RB:"RB",.S:"S"]
    
    var type: Train.Types {
        get {
            return Types(rawValue: self.raw_type)!
        }
        set (newType){
            self.raw_type = newType.rawValue
        }
    }
    
    func stringRepresentation() -> String {
        return String(format: "%@ %@", Train.typeNameMap[self.type] ?? "?", self.number ?? "?")
    }
}
