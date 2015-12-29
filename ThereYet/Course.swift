//
//  Course.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/23/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData


class Course: NSManagedObject {

    @NSManaged var pearson_id: NSNumber?
    @NSManaged var hexColor: String?
    @NSManaged var title: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var locationLat: NSNumber?
    @NSManaged var locationLng: NSNumber?
    @NSManaged var startsAt: NSDate?
    @NSManaged var endsAt: NSDate?
    @NSManaged var classDays: AnyObject?

}

class Course_RegularObject {
    
    var pearson_id: NSNumber?
    var hexColor: String?
    var title: String?
    var createdAt: NSDate?
    var locationLat: NSNumber?
    var locationLng: NSNumber?
    var startsAt: NSDate?
    var endsAt: NSDate?
    var classDays: AnyObject?
    
    func saveAsNSManagedObject() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Course", inManagedObjectContext: context)
        let course = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as? Course
        course?.pearson_id = self.pearson_id
        course?.hexColor = self.hexColor
        course?.title = self.title
        course?.createdAt = self.createdAt
        course?.locationLat = self.locationLat
        course?.locationLng = self.locationLng
        course?.startsAt = self.startsAt
        course?.endsAt = self.endsAt
        course?.classDays = self.classDays
        
        do {
            try context.save()
        } catch {
            print("could not save the course object in Core Data")
        }
    }
}