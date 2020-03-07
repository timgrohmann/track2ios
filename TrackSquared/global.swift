//
//  global.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 07.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var delegate: AppDelegate {
    // swiftlint:disable:next force_cast
    return UIApplication.shared.delegate as! AppDelegate
}

var dataController: DataController {
    // swiftlint:disable:next force_cast
    return (UIApplication.shared.delegate as! AppDelegate).dataController
}

/*var managedObjectContext: NSManagedObjectContext{
    return delegate.persistentContainer.viewContext
}*/

struct NilError: Error {}

extension Optional {
    func unwrap(or error: @autoclosure () -> Error = NilError()) throws -> Wrapped {
        switch self {
        case .some(let w): return w
        case .none: throw error()
        }
    }
}
