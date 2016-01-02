//
//  AddCourseViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/26/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData

class ChooseExistingAddCourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var continueButton: UIBarButtonItem!
    
    var color: UIColor! {
        didSet {
            navigationController?.navigationBar.barTintColor = color
        }
    }
    
    var courses = [Course]()
    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let fetchRequest = NSFetchRequest(entityName: "Course")
        fetchRequest.predicate = NSPredicate(format: "pearson_id != nil && hexColor == nil")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try courses = context.executeFetchRequest(fetchRequest) as! [Course]
        } catch let error as NSError {
            print(error)
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return courses.count
        } else if section == 1 {
            return 1
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        switch indexPath.section {
            case 0:
                let course = courses[indexPath.row]
                cell.textLabel?.text = course.title
                break
            case 1:
                cell.textLabel?.text = "New Course"
                break
            default:
                break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let oldIndexPath = selectedIndexPath {
            let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath)
            oldCell?.accessoryType = .None
        }
        let newCell = tableView.cellForRowAtIndexPath(indexPath)
        newCell?.accessoryType = .Checkmark
        
        selectedIndexPath = indexPath
        
        continueButton.enabled = true
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pearson Courses"
        } else {
            return nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addClassTapped2" {
            let vc = segue.destinationViewController as! AddCourseViewController
            vc.isAdding = true
            if let indexPath = selectedIndexPath {
                if (indexPath.section != 1 && indexPath.row < courses.count) {
                    vc.originalCourse = courses[indexPath.row]
                }
            }
        }
    }
    
}
