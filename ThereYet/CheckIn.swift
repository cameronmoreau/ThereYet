//
//  CheckIn.swift
//  ThereYet
//
//  Created by Cameron Moreau on 1/1/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import CoreData

class CheckIn: NSManagedObject {
    
    @NSManaged var parseKey: String?
    @NSManaged var course: Course?
    @NSManaged var timestamp: NSDate?
    @NSManaged var points: NSNumber?
    
}
