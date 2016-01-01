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
    
    @IBAction func btnHerePressed(sender: AnyObject) {
        self.locationManager.startUpdatingLocation()
    }
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var progressImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var labelTodaysClasses: UILabel!
    @IBOutlet weak var labelCountDown: UILabel!
    @IBOutlet weak var btnHere: UIButton!
    
    let kCheckInRadius: Double = 20 //in meters
    let kCheckInTime = 300 //in seconds
    var timeUntilNextClass: NSTimeInterval?
    
    let pearsonUser = PearsonUser()
    let locationManager = CLLocationManager()
    let locationStorage = LocationStorage()
    
    var courses: [Course]!
    var coursesCompleted = 0

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
        
        loadCourses()
        
        //Amount of courses Completed
        for c in courses! {
            if c.startsAt?.timeIntervalSinceNow < 0 {
                coursesCompleted += 1
            }
        }
        
        //setupForNextClass()
        updateNextClassInterval()
        fixUIForClasses()
        
        //Location data - needs to be fixed later
        if !CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Temp notification
        if courses.count > 0 {
            let localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
            localNotification.alertBody = "\(courses[0].title!) is starting soon"
            localNotification.category = "CLASS"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let time: NSTimeInterval = 1
        
        var progress: CGFloat = 100
        if courses.count > 0 {
            progress = CGFloat((coursesCompleted * 100 / courses.count * 100) / 100)
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
    
    //MARK: - Base Functions
    func loadCourses() {
        let weekdayInt = NSCalendar.currentCalendar().components(.Weekday, fromDate: NSDate()).weekday-1
        let weekday = "\(weekdayInt)"
        
        courses  = [Course]()
        
        //Get the base day staring at 12 am
        let cal = NSCalendar.currentCalendar()
        let calComps = cal.components([.Day, .Month, .Year], fromDate: NSDate())
        
        let baseDay = NSDateComponents()
        baseDay.year = calComps.year
        baseDay.month = calComps.month
        baseDay.day = calComps.day
        
        //base day
        let today = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)?.dateFromComponents(baseDay)

        let fetchRequest = NSFetchRequest(entityName: "Course")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: true)]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "classDays CONTAINS[cd] %@", weekday), NSPredicate(format: "startsAt > %@", today!)])
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try courses = context.executeFetchRequest(fetchRequest) as! [Course]
        } catch let error as NSError {
            print(error)
        }
    }
    
    func updateNextClassInterval() {
        if self.courses.count - coursesCompleted > 0 {
            let nextDate = courses[coursesCompleted].startsAt!
            let currentDate = NSDate()
            
            self.timeUntilNextClass = nextDate.timeIntervalSinceDate(currentDate)
            self.labelCountDown.text = clockText(timeUntilNextClass!)
        }
    }
    
    func checkIn(course: Course) {
        let currentLocation = CLLocation(latitude: locationStorage.location!.latitude, longitude: locationStorage.location!.longitude)
        let courseLocation = CLLocation(latitude: (Double(course.locationLat!) as CLLocationDegrees), longitude: (Double(course.locationLng!) as CLLocationDegrees))
        
        print(courseLocation)
        
        let distance = courseLocation.distanceFromLocation(currentLocation)
        print(distance)
        
        if distance <= kCheckInRadius {
            print("CHECK IN!")
        } else {
            print("You're a liar. You aren't there yet.")
        }
    }
    
    func skip(course: Course) {
        
    }
    
    
    //MARK: - Helper functions
    func fixUIForClasses() {
        self.btnHere.hidden = true
        
        
        if courses.count == coursesCompleted {
            self.tableView.hidden = true
            self.labelTodaysClasses.hidden = true
            self.labelCountDown.text = "15 points earned"
            self.labelHeading.text = "You're all done for today!"
            
            
            self.labelHeading.sizeToFit()
            self.labelCountDown.sizeToFit()
        } else {
            self.tableView.hidden = false
            
            //Class in next 5 minutes
            if shouldShowThere() {
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
    
    //accidently broke this
    func shouldShowThere() -> Bool {
        if let time = self.timeUntilNextClass {
            return Int(time) < kCheckInTime
        }
        
        return false
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
    
    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count - self.coursesCompleted
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TodaysCourseTableViewCell
        
        let course = courses[indexPath.row + self.coursesCompleted]
        
        cell.titleLabel.text = course.title
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell.timeLabel.text = "\(dateFormatter.stringFromDate(course.startsAt!)) - \(dateFormatter.stringFromDate(course.endsAt!))"
        
        cell.colorViewBGColor = UIColor(rgba: course.hexColor!)
        cell.colorView.backgroundColor = UIColor(rgba: course.hexColor!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.row < courses.count {
            let course = courses[indexPath.row + self.coursesCompleted]
            
            let skip = UITableViewRowAction(style: .Default, title: "Skip", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.skip(course)
            })
            
            let imHere = UITableViewRowAction(style: .Normal, title: "I'm Here", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.checkIn(course)
            })
            
            if shouldShowThere() {
                return [imHere]
            } else {
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
            
            //Check for checkin
            if shouldShowThere() {
                checkIn(courses[coursesCompleted])
            }
            
            manager.startMonitoringSignificantLocationChanges()
            locationStorage.updateLocation(location.coordinate)
        }
    }

    //MARK: - Navigation
    override func performAction(menuItem: MenuItem) {
        super.performAction(menuItem)
        
        switch menuItem.name {
            case "Sign Out":
                deleteAllData("Course")
                pearsonUser.authData.destroy()
                pearsonUser.destroy()
                PFUser.logOut()
                
                self.navigateToViewController(MenuItem(storyboardID: "LoginViewController", name: "Login", color: UIColor.lightGrayColor(), action: .Navigation))
                break
            
            case "Show Schedule":
                var courses  = [Course]()
                let fetchRequest = NSFetchRequest(entityName: "Course")
                let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                
                do {
                    try courses = context.executeFetchRequest(fetchRequest) as! [Course]
                    
                    for course in courses {
                        print("Saved course \(course.title)")
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
                
                
                break
            default:
                break
        }
    }

}
