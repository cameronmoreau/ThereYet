//
//  2AddCourseViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/28/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

import THSegmentedControl

class AddCourse2ViewController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var colorCell: UITableViewCell!
    
    @IBOutlet weak var classDaysCell: UITableViewCell!
    
    @IBOutlet weak var startsAtCell: UITableViewCell!
    @IBOutlet weak var endsAtCell: UITableViewCell!
    
    @IBOutlet weak var locationCell: UITableViewCell!
    
    var classDaysSegmentedControl: THSegmentedControl!
    
    var continueButton: UIBarButtonItem!
    
    var course: Course?
    
    var alreadySetUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        continueButton = UIBarButtonItem(title: "Continue", style: .Done, target: self, action: Selector("continueToNextStep"))
        continueButton.tintColor = UIColor.whiteColor()
        continueButton.enabled = false
        self.navigationItem.rightBarButtonItem = continueButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if (course != nil && !alreadySetUp){
            let kClassDaysSegmentedControlPadding: CGFloat = 10
            classDaysSegmentedControl = THSegmentedControl(segments: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
            classDaysSegmentedControl.frame = CGRectMake(kClassDaysSegmentedControlPadding, classDaysCell.frame.size.height/2-34/2, classDaysCell.frame.size.width-(kClassDaysSegmentedControlPadding*2), 34)
            classDaysSegmentedControl.tintColor = self.navigationController?.navigationBar.barTintColor
            classDaysCell.addSubview(classDaysSegmentedControl)
            
            setUpViewController(course!)
            
            alreadySetUp = true
        }
    }
    
    func setUpViewController(course: Course) {
        //title set up
        titleTextField.text = course.title
        
        //color set up
        if (course.hexColor != nil) {
            if course.hexColor!.characters.count != 0 {
                colorCell.backgroundColor = UIColor(rgba: "#\(course.hexColor!)")
            } else {
                colorCell.backgroundColor = UIColor.whiteColor()
                colorCell.textLabel?.text = "No color"
            }
        } else {
            colorCell.backgroundColor = UIColor.whiteColor()
            colorCell.textLabel?.text = "No Color"
            colorCell.textLabel?.textColor = UIColor.redColor()
        }
        
        //TODO: class days set up
        
        //start/end date set up
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy at hh:mm z"
        if course.startsAt != nil {
            startsAtCell.detailTextLabel?.text = dateFormatter.stringFromDate(course.startsAt!)
        } else {
            startsAtCell.detailTextLabel?.text = "None"
            startsAtCell.detailTextLabel?.textColor = UIColor.redColor()
        }
        if course.endsAt != nil {
            endsAtCell.detailTextLabel?.text = dateFormatter.stringFromDate(course.endsAt!)
        } else {
            endsAtCell.detailTextLabel?.text = "None"
            endsAtCell.detailTextLabel?.textColor = UIColor.redColor()
        }
        
        //location set up
        if (course.locationLat != 0 && course.locationLng != 0) {
            locationCell.detailTextLabel?.text = "\(course.locationLat!), \(course.locationLng!)"
        } else {
            locationCell.detailTextLabel?.text = "None"
            locationCell.detailTextLabel?.textColor = UIColor.redColor()
        }
    }
    
    func continueToNextStep() {
        
    }

}
