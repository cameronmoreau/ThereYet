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

import MultiSelectSegmentedControl

class AddCourseViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var colorCell: UITableViewCell!
    
    @IBOutlet weak var classDaysCell: UITableViewCell!

    @IBOutlet weak var startsAtCell: UITableViewCell!
    @IBOutlet weak var endsAtCell: UITableViewCell!
    @IBOutlet weak var startsAtTextField: UITextField!
    @IBOutlet weak var endsAtTextField: UITextField!
    @IBOutlet weak var startsAtLabel: UILabel!
    @IBOutlet weak var endsAtLabel: UILabel!
    
    var isAdding = true
    
    let datePicker = UIDatePicker()
    let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var locationCell: UITableViewCell!
    
    var classDaysSegmentedControl: MultiSelectSegmentedControl!
    
    var saveButton: UIBarButtonItem!
    
    var courseToEdit: Course?
    var course: Course_RegularObject?
    //var course: Course?
    //var managedObjectContext: NSManagedObjectContext!
    
    var alreadySetUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        if course == nil {
            //let entityDescripition = NSEntityDescription.entityForName("Course", inManagedObjectContext: managedObjectContext!)
            //course = Course(entity: entityDescripition!, insertIntoManagedObjectContext: managedObjectContext)
            course = Course_RegularObject()
            course!.title = ""
        } else if course!.pearson_id != nil {
            titleTextField.userInteractionEnabled = false
        }
        
        dateFormatter.dateFormat = "h:mm a"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        saveButton = UIBarButtonItem(title: "Save", style: .Done, target: self, action: Selector("addCourse"))
        saveButton.tintColor = UIColor.whiteColor()
        saveButton.enabled = false
        self.navigationItem.rightBarButtonItem = saveButton
        
        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("checkValidity"), userInfo: nil, repeats: true)
        
        if !isAdding {
            self.title = "Edit Course"
            
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if !alreadySetUp {
            classDaysSegmentedControl = MultiSelectSegmentedControl(items: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
            classDaysSegmentedControl.frame = CGRectMake(0, 0, classDaysCell.frame.size.width, classDaysCell.frame.size.height)
            classDaysSegmentedControl.tintColor = self.navigationController?.navigationBar.barTintColor
            classDaysSegmentedControl.layer.cornerRadius = 0
            classDaysCell.addSubview(classDaysSegmentedControl)
            
            let toolBar = UIToolbar()
            toolBar.barStyle = .Default
            toolBar.translucent = true
            toolBar.tintColor = self.navigationController?.navigationBar.barTintColor
            toolBar.sizeToFit()
            toolBar.userInteractionEnabled = true
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let spaceButton2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "datePickerCancelTap")
            let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "datePickerDoneTap")
            let lblTitle = UILabel(frame: CGRectMake(0, 0, 150, 20))
            lblTitle.backgroundColor = UIColor.clearColor()
            lblTitle.textColor = UIColor.blackColor()
            lblTitle.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
            lblTitle.textAlignment = .Center
            lblTitle.text = "Select Start"
            let titleButton = UIBarButtonItem(customView: lblTitle)
            toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton2, doneButton], animated: false)
            
            let toolBar2 = UIToolbar()
            toolBar2.barStyle = .Default
            toolBar2.translucent = true
            toolBar2.tintColor = self.navigationController?.navigationBar.barTintColor
            toolBar2.sizeToFit()
            toolBar2.userInteractionEnabled = true
            let spaceButton2_ = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let spaceButton3 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let cancelButton2 = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "datePickerCancelTap")
            let doneButton2 = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "datePickerDoneTap")
            let lblTitle2 = UILabel(frame: CGRectMake(0, 0, 150, 20))
            lblTitle2.backgroundColor = UIColor.clearColor()
            lblTitle2.textColor = UIColor.blackColor()
            lblTitle2.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
            lblTitle2.textAlignment = .Center
            lblTitle2.text = "Select End"
            let titleButton2 = UIBarButtonItem(customView: lblTitle2)
            toolBar2.setItems([cancelButton2, spaceButton2_, titleButton2, spaceButton3, doneButton2], animated: false)
            
            datePicker.datePickerMode = .Time
            
            startsAtTextField.inputView = datePicker
            startsAtTextField.inputAccessoryView = toolBar
            
            endsAtTextField.inputView = datePicker
            endsAtTextField.inputAccessoryView = toolBar2
            
            if course != nil {
                setUpViewController(course!)
            }
            
            alreadySetUp = true
        }
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) { //back button pressed
        if (!isAdding && alreadySetUp) {
            if classDaysSegmentedControl != nil {
                var classDayString: String!
                for selectedIndex in classDaysSegmentedControl.selectedSegmentIndexes {
                    if selectedIndex == classDaysSegmentedControl.selectedSegmentIndexes.firstIndex {
                        classDayString = "\(selectedIndex), "
                    } else if selectedIndex == classDaysSegmentedControl.selectedSegmentIndexes.lastIndex {
                        classDayString = "\(classDayString)\(selectedIndex)"
                    } else {
                        classDayString = "\(classDayString)\(selectedIndex), "
                    }
                    
                    if classDaysSegmentedControl.selectedSegmentIndexes.count == 1 {
                        classDayString = "\(selectedIndex)"
                    }
                }
                
                course?.classDays = classDayString
            }
            
            if titleTextField != nil {
                course?.title = titleTextField.text
            }
            
            course?.updateCorrespondingNSManagedObject(courseToEdit!)
        }
    }
    
    func datePickerDoneTap() {
        let calComps = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: datePicker.date)
        
        let baseDayMonthYear = NSDateComponents()
        baseDayMonthYear.year = 1997
        baseDayMonthYear.month = 1
        baseDayMonthYear.day = 4
        baseDayMonthYear.hour = calComps.hour
        baseDayMonthYear.minute = calComps.minute
        
        //base day
        let baseDateWithTime: NSDate! = NSCalendar.currentCalendar().dateFromComponents(baseDayMonthYear)
        
        if startsAtTextField.isFirstResponder() {
            course?.startsAt = baseDateWithTime
            startsAtLabel.text = dateFormatter.stringFromDate(baseDateWithTime)
            startsAtTextField.resignFirstResponder()
            
            startsAtLabel.textColor = UIColor.lightGrayColor()
        } else if endsAtTextField.isFirstResponder()  {
            course?.endsAt = baseDateWithTime
            endsAtLabel.text = dateFormatter.stringFromDate(baseDateWithTime)
            endsAtTextField.resignFirstResponder()
            
            endsAtLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    func datePickerCancelTap() {
        startsAtTextField.resignFirstResponder()
        endsAtTextField.resignFirstResponder()
    }
    
    func setUpViewController(course: Course_RegularObject) {
        //title set up
        titleTextField.text = course.title
        
        //color set up
        if (course.hexColor != nil) {
            if course.hexColor!.characters.count != 0 {
                colorCell.textLabel?.text = ""
                colorCell.backgroundColor = UIColor(rgba: "\(course.hexColor!)")
            }
        }
        
        let tempClassDaysArray = course.classDays?.componentsSeparatedByString(", ")
        let classDays = NSMutableIndexSet()
        if tempClassDaysArray != nil {
            for classDay in tempClassDaysArray! {
                classDays.addIndex(Int(classDay)!)
            }
        }
        if classDays.count > 0 {
            classDaysSegmentedControl.selectedSegmentIndexes = classDays
        }
        
        //start/end date set up
        if course.startsAt != nil {
            startsAtLabel.text = dateFormatter.stringFromDate(course.startsAt!)
            startsAtLabel.textColor = UIColor.lightGrayColor()
        }
        if course.endsAt != nil {
            endsAtLabel.text = dateFormatter.stringFromDate(course.endsAt!)
            endsAtLabel.textColor = UIColor.lightGrayColor()
        }
        
        //location set up
        if ((course.locationLat != 0 && course.locationLng != 0) && (course.locationLat != nil && course.locationLng != nil)) {
            locationCell.detailTextLabel?.text = "\(course.locationLat!), \(course.locationLng!)"
            locationCell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        }
    }
    
    func addCourse() {
        var classDayString: String!
        for selectedIndex in classDaysSegmentedControl.selectedSegmentIndexes {
            if selectedIndex == classDaysSegmentedControl.selectedSegmentIndexes.firstIndex {
                classDayString = "\(selectedIndex), "
            } else if selectedIndex == classDaysSegmentedControl.selectedSegmentIndexes.lastIndex {
                classDayString = "\(classDayString)\(selectedIndex)"
            } else {
                classDayString = "\(classDayString)\(selectedIndex), "
            }
            
            if classDaysSegmentedControl.selectedSegmentIndexes.count == 1 {
                classDayString = "\(selectedIndex)"
            }
        }
        course?.classDays = classDayString
        
        course?.title = titleTextField.text
        
        course?.createdAt = NSDate()
        
        course?.pearson_id = nil
        
        course?.saveAsNSManagedObject()
        /*do {
            try managedObjectContext.save()
        } catch {
            print("Couldn't update")
        }*/
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkValidity() {
        if (course != nil && course?.hexColor != nil &&  titleTextField.text?.characters.count > 0 && course?.locationLat != 0 && course?.locationLng != 0 && course?.locationLat != nil && course?.locationLng != nil && course?.startsAt != nil && course?.endsAt != nil && classDaysSegmentedControl.selectedSegmentIndexes.count != 0) {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectLocationSegue" {
            let mapVC = segue.destinationViewController as! SelectLocationViewController
            mapVC.delegate = self
            
            //Set previous location
            if (course?.locationLat != 0 && course?.locationLng != 0 && course?.locationLat != nil && course?.locationLng != nil) {
                mapVC.selectedLocation = CLLocationCoordinate2DMake(course?.locationLat as! Double, course?.locationLng as! Double)
            }
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
        course?.locationLat = location.latitude
        course?.locationLng = location.longitude
        
        locationCell.detailTextLabel?.text = "\(location.latitude), \(location.longitude)"
        locationCell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        //self.navigationController?.popViewControllerAnimated(true)
    }
}

class NoCopyPasteTextField: UITextField {
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "paste:" {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
