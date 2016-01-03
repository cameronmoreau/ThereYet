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
import Foundation

class Course: NSManagedObject {
    
    @NSManaged var parseKey: String?
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
    
    func toRegularObject() -> Course_RegularObject {
        let c = Course_RegularObject()
        c.parseKey = self.parseKey
        c.pearson_id = self.pearson_id
        c.hexColor = self.hexColor
        c.title = self.title
        c.locationLat = self.locationLat
        c.locationLng = self.locationLng
        c.startsAt = self.startsAt
        c.endsAt = self.endsAt
        c.classDays = self.classDays
        c.createdAt = self.createdAt
        c.updatedAt = self.updatedAt
        return c
    }
}

class Course_RegularObject {
    
    var parseKey: String?
    var pearson_id: NSNumber?
    var hexColor: String?
    var title: String?
    var locationLat: NSNumber?
    var locationLng: NSNumber?
    var startsAt: NSDate?
    var endsAt: NSDate?
    var classDays: String?
    var updatedAt: NSDate?
    var createdAt: NSDate?
    
    init() {
    }
    
    init(parseObject: PFObject) {
        let location = parseObject["location"] as? PFGeoPoint
        
        self.parseKey = parseObject.objectId
        self.pearson_id = parseObject["pearsonId"] as? NSNumber
        self.hexColor = parseObject["hexColor"] as? String
        self.title = parseObject["title"] as? String
        self.locationLat = location?.latitude
        self.locationLng = location?.longitude
        self.startsAt = parseObject["startsAt"] as? NSDate
        self.endsAt = parseObject["endsAt"] as? NSDate
        self.classDays = parseObject["classDays"] as? String
        self.createdAt = parseObject.createdAt! as NSDate
        self.updatedAt = parseObject.updatedAt! as NSDate
    }
    
    //lol Fuck it ship it, too late now
    func toPFObject() -> PFObject {
        let obj = PFObject(className: "Course")
        obj["user"] = PFUser.currentUser()
        
        if self.parseKey != nil {
            obj.objectId = self.parseKey
        }
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
    
    func daysOfWeek() -> [Int]? {
        if let days = self.classDays {
            var result = [Int]()
            
            let ds = days.componentsSeparatedByString(", ")
            for d in ds {
                result.append(Int(d)!)
            }
            
            return result
        }
        
        return nil
    }
    
    func setupNotifications () {
        //delete old
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification]
        for n in notifications {
            let uuid = n.userInfo!["uuid"] as! String
            if uuid.rangeOfString(self.title!) != nil {
                print("Canceling notification")
                UIApplication.sharedApplication().cancelLocalNotification(n)
            }
        }
        
        let calComps = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate())
        
        let baseDayMonthYear = NSDateComponents()
        baseDayMonthYear.year = 1997
        baseDayMonthYear.month = 1
        baseDayMonthYear.day = 4
        baseDayMonthYear.hour = calComps.hour
        baseDayMonthYear.minute = calComps.minute
        
        //setup new
        if let days = self.daysOfWeek() {
            for d in days {
                let localNotification = UILocalNotification()
                localNotification.userInfo = ["uuid": "\(self.title!)-\(d)"]
                localNotification.fireDate = self.startsAt!.dateByAddingTimeInterval(-300)
                localNotification.alertBody = "\(self.title!) is starting soon"
                localNotification.category = "CLASS"
                localNotification.timeZone = NSTimeZone.defaultTimeZone()
                localNotification.repeatInterval = .WeekOfYear
                
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
        }
    }
    
    func saveAsNSManagedObject() -> Course? {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("Course", inManagedObjectContext: context)
        let course = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as? Course
        
        course?.parseKey = self.parseKey
        course?.pearson_id = self.pearson_id
        course?.hexColor = self.hexColor
        course?.title = self.title
        course?.locationLat = self.locationLat
        course?.locationLng = self.locationLng
        course?.startsAt = self.startsAt
        course?.endsAt = self.endsAt
        course?.classDays = self.classDays
        course?.createdAt = self.createdAt
        course?.updatedAt = self.updatedAt
        
        if self.updatedAt == nil || self.createdAt == nil {
            course?.createdAt = NSDate()
            course?.updatedAt = NSDate()
        }
        
        setupNotifications()
        
        do {
            try context.save()
        } catch {
            print("could not save the course object in Core Data")
        }
        
        return course
    }
    
    func updateCorrespondingNSManagedObject(courseToEdit: Course?) {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        courseToEdit?.parseKey = self.parseKey
        courseToEdit?.pearson_id = self.pearson_id
        courseToEdit?.hexColor = self.hexColor
        courseToEdit?.title = self.title
        courseToEdit?.updatedAt = NSDate()
        courseToEdit?.locationLat = self.locationLat
        courseToEdit?.locationLng = self.locationLng
        courseToEdit?.startsAt = self.startsAt
        courseToEdit?.endsAt = self.endsAt
        courseToEdit?.classDays = self.classDays
        
        setupNotifications()
        
        do {
            try context.save()
        } catch {
            print("could not update the course object in Core Data")
        }
    }
    
}