//
//  CheckIn.swift
//  ThereYet
//
//  Created by Cameron Moreau on 1/1/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import CoreData
import UIKit

class CheckIn: NSManagedObject {
    
    @NSManaged var parseKey: String?
    @NSManaged var course: Course?
    @NSManaged var timestamp: NSDate?
    @NSManaged var points: NSNumber?
    
}

class CheckIn_RegularObject {
    var parseKey: String?
    var course: Course?
    var timestamp: NSDate?
    var points: NSNumber?
    
    func saveAsNSManagedObject() -> CheckIn? {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("CheckIn", inManagedObjectContext: context)
        let check = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as? CheckIn
        
        check?.parseKey = self.parseKey
        check?.course = self.course
        check?.timestamp = self.timestamp
        check?.points = self.points
        
        do {
            try context.save()
        } catch {
            print("could not save the course object in Core Data")
        }
        
        return check!
    }
}
