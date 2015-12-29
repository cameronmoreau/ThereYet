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
    @IBOutlet weak var startsAtTextField: UITextField!
    @IBOutlet weak var endsAtTextField: UITextField!
    @IBOutlet weak var startsAtLabel: UILabel!
    @IBOutlet weak var endsAtLabel: UILabel!
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var locationCell: UITableViewCell!
    
    var classDaysSegmentedControl: THSegmentedControl!
    
    var saveButton: UIBarButtonItem!
    
    var course: Course_RegularObject?
    
    var alreadySetUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if course == nil {
            course = Course_RegularObject()
            course!.title = ""
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        saveButton = UIBarButtonItem(title: "Save", style: .Done, target: self, action: Selector("addCourse"))
        saveButton.tintColor = UIColor.whiteColor()
        saveButton.enabled = false
        self.navigationItem.rightBarButtonItem = saveButton
        
        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("checkValidity"), userInfo: nil, repeats: true)
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
            
            let toolBar = UIToolbar()
            toolBar.barStyle = .Default
            toolBar.translucent = true
            toolBar.tintColor = self.navigationController?.navigationBar.barTintColor
            toolBar.sizeToFit()
            toolBar.userInteractionEnabled = true
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "datePickerCancelTap")
            let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "datePickerDoneTap")
            toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
            
            datePicker.datePickerMode = .DateAndTime
            startsAtTextField.inputView = datePicker
            startsAtTextField.inputAccessoryView = toolBar
            
            datePicker.datePickerMode = .DateAndTime
            endsAtTextField.inputView = datePicker
            endsAtTextField.inputAccessoryView = toolBar
            
            if course != nil {
                setUpViewController(course!)
            }
            
            alreadySetUp = true
        }
    }
    
    func datePickerDoneTap() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy; h:mm a"
        
        if startsAtTextField.isFirstResponder() {
            course?.startsAt = datePicker.date
            startsAtLabel.text = dateFormatter.stringFromDate(datePicker.date)
            startsAtTextField.resignFirstResponder()
            
            startsAtLabel.textColor = UIColor.lightGrayColor()
        } else if endsAtTextField.isFirstResponder()  {
            course?.endsAt = datePicker.date
            endsAtLabel.text = dateFormatter.stringFromDate(datePicker.date)
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
                colorCell.backgroundColor = UIColor(rgba: "#\(course.hexColor!)")
            }
        }
        
        let tempClassDaysArray = course.classDays?.componentsSeparatedByString(", ")
        var classDaysArray = [Int]()
        if tempClassDaysArray != nil {
            for classDay in tempClassDaysArray! {
                classDaysArray.append(Int(classDay)!)
            }
        }
        if classDaysArray.count > 0 {
            classDaysSegmentedControl.setSelectedIndexes(NSOrderedSet(array: classDaysArray))
        }
        
        //start/end date set up
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy; h:mm a"
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
        for selectedIndex in classDaysSegmentedControl.selectedIndexes() {
            if (selectedIndex as! Int) == (classDaysSegmentedControl.selectedIndexes().lastObject as! Int) {
                classDayString = "\(classDayString)\(selectedIndex)"
            } else if (selectedIndex as! Int) == (classDaysSegmentedControl.selectedIndexes().firstObject as! Int) {
                classDayString = "\(selectedIndex), "
            } else {
                classDayString = "\(classDayString)\(selectedIndex), "
            }
        }
        course?.classDays = classDayString
        
        course?.title = titleTextField.text
        
        course?.createdAt = NSDate()
        
        course?.pearson_id = nil
        
        course?.saveAsNSManagedObject()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkValidity() {
        if (course != nil && course?.hexColor != nil &&  titleTextField.text?.characters.count > 0 && course?.locationLat != 0 && course?.locationLng != 0 && course?.locationLat != nil && course?.locationLng != nil && course?.startsAt != nil && course?.endsAt != nil && classDaysSegmentedControl.selectedIndexes().count != 0) {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
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
        course?.locationLat = location.latitude
        course?.locationLng = location.longitude
        
        locationCell.detailTextLabel?.text = "\(location.latitude), \(location.longitude)"
        locationCell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        //self.navigationController?.popViewControllerAnimated(true)
    }
}
