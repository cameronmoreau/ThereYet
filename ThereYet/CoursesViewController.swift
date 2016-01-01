//
//  CoursesViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/24/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData

class CoursesViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var courses: [Course]!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        courses  = [Course]()
        let fetchRequest = NSFetchRequest(entityName: "Course")
        fetchRequest.predicate = NSPredicate(format: "pearson_id == nil")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try courses = context.executeFetchRequest(fetchRequest) as! [Course]
        } catch let error as NSError {
            print(error)
        }
        
        tableView.reloadData()
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        if courses.count == 0 {
            updateUIForEmptyState()
        }
    }
    
    func updateUIForEmptyState() {
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(5, 0, 0, 0)
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TodaysCourseTableViewCell
        
        let course = courses[indexPath.row]

        cell.titleLabel.text = course.title
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell.timeLabel.text = "\(dateFormatter.stringFromDate(course.startsAt!)) - \(dateFormatter.stringFromDate(course.endsAt!))"
        
        cell.colorViewBGColor = UIColor(rgba: course.hexColor!)
        cell.colorView.backgroundColor = UIColor(rgba: course.hexColor!)
        
        let tempClassDaysArray = course.classDays?.componentsSeparatedByString(", ")
        let classDays = NSMutableIndexSet()
        if tempClassDaysArray != nil {
            for classDay in tempClassDaysArray! {
                classDays.addIndex(Int(classDay)!)
            }
        }
        if classDays.count > 0 {
            cell.segmentedControl?.selectedSegmentIndexes = classDays
        }
        cell.segmentedControl?.tintColor = UIColor(rgba: course.hexColor!)
        //cell.segmentedControl?.layer.borderColor = UIColor(rgba: course.hexColor!).CGColor
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let course = courses[indexPath.row]
            
            let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            context.deleteObject(course)
            courses.removeAtIndex(indexPath.row)
            do {
                try context.save()
            } catch {
                print("Couldn't delete course, \(course).")
            }
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        updateUIForEmptyState()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addClassTapped" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.viewControllers.first as! ChooseExistingAddCourseViewController
            vc.color = self.color
        }
        
        if segue.identifier == "editCourse" {
            let vc = segue.destinationViewController as! AddCourseViewController
            vc.isAdding = false
            
//            let tempCourse = courses[tableView.indexPathForSelectedRow!.row]
//            
//            let course = Course_RegularObject()
//            course.pearson_id = tempCourse.pearson_id
//            course.hexColor = tempCourse.hexColor
//            course.title = tempCourse.title
//            course.createdAt = tempCourse.createdAt
//            course.locationLat = tempCourse.locationLat
//            course.locationLng = tempCourse.locationLng
//            course.startsAt = tempCourse.startsAt
//            course.endsAt = tempCourse.endsAt
//            course.classDays = tempCourse.classDays
            
            vc.course = courses[tableView.indexPathForSelectedRow!.row]
        }
    }
    
}
