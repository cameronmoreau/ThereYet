//
//  Course.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/23/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData
import Parse

class Course: NSManagedObject {

    @NSManaged var pearson_id: NSNumber?
    @NSManaged var hexColor: String?
    @NSManaged var title: String?
    @NSManaged var locationLat: NSNumber?
    @NSManaged var locationLng: NSNumber?
    @NSManaged var startsAt: NSDate?
    @NSManaged var endsAt: NSDate?
    @NSManaged var classDays: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var updatedAt: NSDate?
    
    func update() {
    
    }

}

class Course_RegularObject {
    
    var pearson_id: NSNumber?
    var hexColor: String?
    var title: String?
    var locationLat: NSNumber?
    var locationLng: NSNumber?
    var startsAt: NSDate?
    var endsAt: NSDate?
    var classDays: String?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    init() {
    }
    
    init(parseObject: PFObject) {
        let location = parseObject["location"] as? PFGeoPoint
        
        self.pearson_id = parseObject["pearsonId"] as? NSNumber
        self.hexColor = parseObject["hexColor"] as? String
        self.title = parseObject["title"] as? String
        self.locationLat = location?.latitude
        self.locationLng = location?.longitude
        self.startsAt = parseObject["startsAt"] as? NSDate
        self.endsAt = parseObject["endsAt"] as? NSDate
        self.classDays = parseObject["classDays"] as? String
        self.createdAt = parseObject["createdAt"] as? NSDate
        self.updatedAt = parseObject["updatedAt"] as? NSDate
    }
    
    //lol Fuck it ship it, too late now
    func toPFObject() -> PFObject {
        let obj = PFObject(className: "Course")
        obj["user"] = PFUser.currentUser()
        
        if self.pearson_id != nil {
            obj["pearsonId"] = self.pearson_id
        }
        if self.hexColor != nil {
            obj["hexColor"] = self.hexColor
        }
        if self.title != nil {
            obj["title"] = self.title
        }
        if self.startsAt != nil {
            obj["startsAt"] = self.startsAt
        }
        if self.endsAt != nil {
            obj["endsAt"] = self.endsAt
        }
        if self.classDays != nil {
            obj["classDays"] = self.classDays
        }
        if self.locationLat != nil && self.locationLng != nil {
            obj["location"] = PFGeoPoint(latitude: self.locationLat as! Double, longitude: self.locationLng as! Double)
        }
        
        return obj
    }
    
    func saveAsNSManagedObject() -> Course? {
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
        
        return course
    }
}