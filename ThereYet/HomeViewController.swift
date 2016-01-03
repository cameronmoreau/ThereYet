//
//  HomeViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/21/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Parse
import MBCircularProgressBar

class HomeViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBAction func btnHerePressed(sender: AnyObject?) {
        if canCheckIn() {
            self.attemptedCheckin = false
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var progressImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var labelTodaysClasses: UILabel!
    @IBOutlet weak var labelCountDown: UILabel!
    @IBOutlet weak var btnHere: UIButton!
    
    var kNumCoursesTotal = 0
    let kCheckInRadius: Double = 20 //in meters
    let kCheckInTime = 300 //in seconds
    var timeUntilNextClass: NSTimeInterval?
    
    let pearsonUser = PearsonUser()
    let locationManager = CLLocationManager()
    let locationStorage = LocationStorage()
    let checkinManager = CheckInManager()
    
    var courses = [Course]()
    var lastCheckin: CheckIn?
    var attemptedCheckin = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //Table
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        loadData()
        updateNextClassInterval()
        fixUIForClasses()
        
        //Location data - needs to be fixed later
        if !CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let time: NSTimeInterval = 1
        
        var progress: CGFloat = 100
        if courses.count > 0 {
            progress = CGFloat(Double(Double(kNumCoursesTotal - courses.count)/Double(kNumCoursesTotal)) * 100)
        }
        self.progressBar.setValue(progress, animateWithDuration: time)
        
        //Show check
        if progress == 100 {
            let delay = time * Double(NSEC_PER_SEC)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.progressImage.image = UIImage(named: "ic_check.png")
                
                let transition = CATransition()
                transition.duration = 1
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFade
                
                self.progressImage.layer.addAnimation(transition, forKey: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteAllData(entity: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            print(results)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    func signOut() {
        deleteAllData("Course")
        
        let pearsonUser = PearsonUser()
        pearsonUser.authData.destroy()
        pearsonUser.destroy()
        PFUser.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = loginVC
    }
    
    override func performAction(menuItem: MenuItem) {
        if menuItem.name == "Sign Out" {
            signOut()
        }
    }
    
    //MARK: - Base Functions
    func loadData() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let weekdayInt = NSCalendar.currentCalendar().components(.Weekday, fromDate: NSDate()).weekday-1
        let weekday = "\(weekdayInt)"
        
        //Courses
        let courseFetch = NSFetchRequest(entityName: "Course")
        courseFetch.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: true)]
        courseFetch.predicate = NSPredicate(format: "classDays CONTAINS[cd] %@", weekday)
        
        do {
            try courses = context.executeFetchRequest(courseFetch) as! [Course]
            kNumCoursesTotal = courses.count
            
            var tempCourses = [Course]()
            for course in courses {
                
                let ti = NSInteger(course.startsAt!.convertToBaseDate().timeIntervalSinceDate(NSDate().convertToBaseDate()))
                if ti > 0 {
                    tempCourses.append(course)
                }
            }
            courses.removeAll()
            courses.appendContentsOf(tempCourses)
        } catch let error as NSError {
            print(error)
        }
        
        //Checkins
        self.lastCheckin = self.checkinManager.lastCheckin()
    }
    
    func updateNextClassInterval() {
        if self.courses.count > 0 {
            let nextDate = courses[0].startsAt!.convertToBaseDate()
            let currentDate = NSDate().convertToBaseDate()
            
            self.timeUntilNextClass = nextDate.timeIntervalSinceDate(currentDate)
            self.labelCountDown.text = clockText(timeUntilNextClass!)
        }
    }
    
    func canCheckIn() -> Bool {
        if attemptedCheckin {
            return false
        }
        
        if let next = timeUntilNextClass {
            if Int(next) < kCheckInTime {
                if let last = lastCheckin {
                    let lastInterval = Int(last.timestamp!.timeIntervalSinceNow)
                    if lastInterval + kCheckInTime > Int(next) && last.course == courses[0] {
                        self.labelCountDown.text = "You have arrived!"
                        return false
                    }
                }
                
                return true
            }
        }
        
        return false
    }
    
    func checkIn(course: Course, currentLocation: CLLocation) {
        let courseLocation = CLLocation(latitude: (Double(course.locationLat!) as CLLocationDegrees), longitude: (Double(course.locationLng!) as CLLocationDegrees))
        let distance = courseLocation.distanceFromLocation(currentLocation)
        
        if distance <= kCheckInRadius {
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let entity = NSEntityDescription.entityForName("CheckIn", inManagedObjectContext: context)
            let checkIn = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as? CheckIn
            
            checkIn?.timestamp = NSDate()
            checkIn?.course = courses[0]
            checkIn?.points = Int(10 / kNumCoursesTotal) //FIXME: needs to be fixed if time
            
            do {
                try context.save()
                self.lastCheckin = checkIn
                self.btnHere.hidden = true
                self.labelCountDown.text = "You have arrived!"
                
                let alertController = UIAlertController(title: "Congrats!", message: "You earned \(checkIn!.points!) points", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion:nil)
            } catch {
                print("error saving")
            }
        } else {
            let alertController = UIAlertController(title: "You aren't there yet!", message: "You are \(Int(distance)) meters from the location of your class! Nice try!", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Darn, you caught me!", style: .Cancel, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion:nil)
        }
    }
    
    func skip(course: Course) {
        
    }
    
    
    //MARK: - Helper functions
    func fixUIForClasses() {
        self.btnHere.hidden = true
        
        if courses.count == 0 {
            self.tableView.hidden = true
            self.labelTodaysClasses.hidden = true
            self.labelCountDown.text = "\(self.checkinManager.totalPointsToday()) points earned"
            self.labelHeading.text = "You're all done for today!"
            
            
            self.labelHeading.sizeToFit()
            self.labelCountDown.sizeToFit()
        } else {
            self.tableView.hidden = false
            
            if canCheckIn() {
                self.btnHere.hidden = false
            }
        }
    }
    
    func clockText(interval: NSTimeInterval) -> String {
        let ti = Int(interval) + 60
        var output = ""
        
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if hours > 0 {
            output += String(format: "%d Hours ", arguments: [hours])
        }
        
        return output + String(format: "%d Minutes", arguments: [minutes])
    }
    
    // MARK: - Table View
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
        cell.timeLabel.text = "\(dateFormatter.stringFromDate(course.startsAt!.convertToBaseDate())) - \(dateFormatter.stringFromDate(course.endsAt!))"
        
        cell.colorViewBGColor = UIColor(rgba: course.hexColor!)
        cell.colorView.backgroundColor = UIColor(rgba: course.hexColor!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.row < courses.count {
            let course = courses[indexPath.row]
            
            let skip = UITableViewRowAction(style: .Default, title: "Skip", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.skip(course)
            })

            let imHere = UITableViewRowAction(style: .Normal, title: "I'm Here", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.btnHerePressed(nil)
            })

            let ti = NSInteger(course.startsAt!.convertToBaseDate().timeIntervalSinceDate(NSDate().convertToBaseDate()))
            let minutes = (ti / 60) % 60
            let hours = (ti / 3600)
            
            if (hours == 0 && minutes <= 5) {
                return [imHere]
                //return [imHere, skip]
            } else {
                //return nil
                return [skip]
            }
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(5, 0, 0, 0)
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    // MARK: - Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //If a location was found, store it
        if let location = manager.location {
            if canCheckIn() {
                self.attemptedCheckin = true
                self.checkIn(courses[0], currentLocation: location)
                manager.stopMonitoringSignificantLocationChanges()
            }
            
            manager.startMonitoringSignificantLocationChanges()
            locationStorage.updateLocation(location.coordinate)
        }
    }

}
