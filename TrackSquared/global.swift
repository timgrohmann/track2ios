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

var delegate: AppDelegate{
    return UIApplication.shared.delegate as! AppDelegate
}

var managedObjectContext: NSManagedObjectContext{
    return delegate.persistentContainer.viewContext
}
