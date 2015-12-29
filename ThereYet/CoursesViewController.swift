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
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addClassTapped" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.viewControllers.first as! ChooseExistingAddCourseViewController
            vc.color = self.color
        }
    }
    
}
