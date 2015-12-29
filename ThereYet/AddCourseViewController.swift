//
//  2AddCourseViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/28/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

import THSegmentedControl

class AddCourseViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var colorCell: UITableViewCell!
    
    @IBOutlet weak var classDaysCell: UITableViewCell!
    
    @IBOutlet weak var startsAtCell: UITableViewCell!
    @IBOutlet weak var endsAtCell: UITableViewCell!
    
    @IBOutlet weak var locationCell: UITableViewCell!
    
    var classDaysSegmentedControl: THSegmentedControl!
    
    var continueButton: UIBarButtonItem!
    
    var course: Course_RegularObject?
    
    var alreadySetUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        continueButton = UIBarButtonItem(title: "Continue", style: .Done, target: self, action: Selector("continueToNextStep"))
        continueButton.tintColor = UIColor.whiteColor()
        continueButton.enabled = false
        self.navigationItem.rightBarButtonItem = continueButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if !alreadySetUp {
            let kClassDaysSegmentedControlPadding: CGFloat = 8
            classDaysSegmentedControl = THSegmentedControl(segments: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
            classDaysSegmentedControl.frame = CGRectMake(kClassDaysSegmentedControlPadding, classDaysCell.frame.size.height/2-36/2, classDaysCell.frame.size.width-(kClassDaysSegmentedControlPadding*2), 36)
            classDaysSegmentedControl.tintColor = self.navigationController?.navigationBar.barTintColor
            classDaysCell.addSubview(classDaysSegmentedControl)
            
            if course != nil {
                setUpViewController(course!)
            }
            
            alreadySetUp = true
        }
    }
    
    func setUpViewController(course: Course_RegularObject) {
        //title set up
        titleTextField.text = course.title
        
        //color set up
        if (course.hexColor != nil) {
            if course.hexColor!.characters.count != 0 {
                colorCell.textLabel?.text = ""
                colorCell.backgroundColor = UIColor(rgba: "#\(course.hexColor!)")
            }
        }
        
        //TODO: class days set up
        
        //start/end date set up
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy at hh:mm z"
        if course.startsAt != nil {
            startsAtCell.detailTextLabel?.text = dateFormatter.stringFromDate(course.startsAt!)
        }
        if course.endsAt != nil {
            endsAtCell.detailTextLabel?.text = dateFormatter.stringFromDate(course.endsAt!)
        }
        
        //location set up
        if (course.locationLat != 0 && course.locationLng != 0) {
            locationCell.detailTextLabel?.text = "\(course.locationLat!), \(course.locationLng!)"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateTableView() {
        if course != nil {
            if course!.hexColor != nil {
                colorCell.textLabel?.text = ""
                colorCell.backgroundColor = UIColor(rgba: course!.hexColor!)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectLocationSegue" {
            let mapVC = segue.destinationViewController as! SelectLocationViewController
            mapVC.delegate = self
            //Do location stuff
            //mapVC.markerPoint = selectedEvent.getLocationGPS()
            //mapVC.markerTitle = selectedEvent.title
        }
        
        if segue.identifier == "selectColor" {
            let vc = segue.destinationViewController as! SelectColorViewController
            vc.addCourseViewController = self
            if (course?.hexColor != nil && course != nil) {
                if let indexRow = vc.colors.indexOf(course!.hexColor!) {
                    vc.selectedIndex = NSIndexPath(forRow: indexRow, inSection: 0)
                }
            }
        }
    }

}

extension AddCourseViewController : SelectLocationDelegate {
    func locationSelected(location: CLLocationCoordinate2D) {
        locationCell.detailTextLabel?.text = "\(location.latitude), \(location.longitude)"
        //self.navigationController?.popViewControllerAnimated(true)
    }
}
