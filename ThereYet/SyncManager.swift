//
//  SyncManager.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/30/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Parse
import CoreData

class SyncManager {

    private static let KEY_LAST_SYNC = "lastSyncedAt"
    
    //This should be run on the login and will return new courses not in parse
    static func runInitalSync(loadedCourses: [Course_RegularObject], completion: ((courses: [Course_RegularObject]) -> ())) {
        self.parseCourses(nil) {
            (courses: [PFObject]) -> () in
            
            var returned = [Course_RegularObject]()
            
            for c in loadedCourses {
                let i = courses.indexOf({$0["title"] as? String == c.title})
                if i == nil {
                    returned.append(c)
                }
            }
            
            completion(courses: returned)
        }
    }
    
    static func fullUpload(courses: [Course_RegularObject], completion: ((success: Bool) -> ())) {
        for c in courses {
            let pfCourse = c.toPFObject()
            pfCourse.saveInBackground()
        }
        
        completion(success: true)
    }
    
    static func fullDownload(completion: ((success: Bool) -> ())) {
        self.parseCourses(nil) {
            (courses: [PFObject]) -> () in
            
            for c in courses {
                let course = Course_RegularObject(parseObject: c)
                course.saveAsNSManagedObject()
            }
            
            completion(success: true)
        }
    }
    
    //All data is uploaded - Store all in parse
    //All data is downloaded - Save all to phone
    //Mixed
    // SELECT * WHERE
    static func runSync(completion: ((error: NSError?) -> ())) {
        let syncDate = NSUserDefaults.standardUserDefaults().objectForKey(KEY_LAST_SYNC) as? NSDate
    }
    
    private static func parseCourses(lastSync: NSDate?, completion: (([PFObject]) -> ())) {
        let query = PFQuery(className: "Course")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            
            completion(objects!)
        }
    }
    
    private static func updateDate() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSDate(), forKey: KEY_LAST_SYNC)
        defaults.synchronize()
    }

}
