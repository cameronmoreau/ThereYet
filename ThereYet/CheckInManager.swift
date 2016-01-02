//
//  PointsManager.swift
//  ThereYet
//
//  Created by Cameron Moreau on 1/2/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CheckInManager {
    
    private let entityName = "CheckIn"
    var context: NSManagedObjectContext!
    
    init() {
        self.context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func checkins() -> [CheckIn] {
        let checkFetch = NSFetchRequest(entityName: "CheckIn")
        checkFetch.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        checkFetch.fetchLimit = 1
        
        do {
            return try context.executeFetchRequest(checkFetch) as! [CheckIn]
        } catch let error as NSError {
            print(error)
        }
        
        return []
    }
    
    func lastCheckin() -> CheckIn? {
        let checkFetch = NSFetchRequest(entityName: "CheckIn")
        checkFetch.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        checkFetch.fetchLimit = 1
        
        var checkins = [CheckIn]()
        
        do {
            try checkins = context.executeFetchRequest(checkFetch) as! [CheckIn]
            return checkins.popLast()
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
    
    func totalPointsToday() -> Int {
        var total = 0
        let current = NSDate()
        
        //Make request
        var checkins = [CheckIn]()
        let request = NSFetchRequest(entityName: self.entityName)
        request.predicate = NSPredicate(format: "timestamp >= %@ && timestamp <= %@", current.stripTime(), current)
        
        do {
            try checkins = context.executeFetchRequest(request) as! [CheckIn]
            for c in checkins {
                total += Int(c.points!)
            }
        } catch let error as NSError {
            print("Could not generate points \(error)")
        }
        
        
        return total
    }
    
    
}