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
        if let time = self.timeUntilNextClass {
            if Int(time) < kCheckInTime {
                self.shouldCheckIn = true
                self.locationManager.startUpdatingLocation()
            }
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
    
    var courses: [Course]!
    
    var coursesPast: [Course]!
    
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
        updateProgressBar()
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
        
        let fetchRequest = NSFetchRequest(entityName: "Course")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "classDays CONTAINS[cd] %@", weekday)
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try courses = context.executeFetchRequest(fetchRequest) as! [Course]
            
            kNumCoursesTotal = courses.count
            
            var tempCourses = [Course]()
            coursesPast = [Course]()
            for course in courses {
                let ti = NSInteger(convertDateToBaseDate(course.startsAt!).timeIntervalSinceDate(convertDateToBaseDate(NSDate())))
                if ti > 0 {
                    tempCourses.append(course)
                } else {
                    coursesPast.append(course)
                }
            }
            courses.removeAll()
            courses.appendContentsOf(tempCourses)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func convertDateToBaseDate(date: NSDate) -> NSDate {
        let calComps = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: date)
        
        let baseDayMonthYear = NSDateComponents()
        baseDayMonthYear.year = 1997
        baseDayMonthYear.month = 1
        baseDayMonthYear.day = 4
        baseDayMonthYear.hour = calComps.hour
        baseDayMonthYear.minute = calComps.minute
        
        //base day
        return NSCalendar.currentCalendar().dateFromComponents(baseDayMonthYear)!
    }
    
    func updateProgressBar() {
        let time: NSTimeInterval = 1
        
        var progress: CGFloat = 100
        print(coursesPast.count, kNumCoursesTotal, coursesCompleted)
        progress = CGFloat(Double(Double(coursesPast.count+coursesCompleted)/Double(kNumCoursesTotal)) * 100)
        self.progressBar.setValue(progress, animateWithDuration: time)
        
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
    
    func updateNextClassInterval() {
        if self.courses.count > 0 {
            let nextDate = convertDateToBaseDate(courses[coursesCompleted].startsAt!)
            let currentDate = convertDateToBaseDate(NSDate())
            
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
            coursesCompleted++
            updateProgressBar()
            updateNextClassInterval()
            self.tableView.reloadData()
        } else {
            print("You're a liar. You aren't there yet.")
            
            let alertController = UIAlertController(title: "You aren't there yet!", message: "You are \(Int(distance)) meters from the location of your class! Nice try!", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Darn, you caught me!", style: .Cancel) { (action:UIAlertAction!) in
                
            }
            alertController.addAction(cancelAction)
            
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
            self.labelCountDown.text = "15 points earned"
            self.labelHeading.text = "You're all done for today!"
            
            
            self.labelHeading.sizeToFit()
            self.labelCountDown.sizeToFit()
        } else {
            self.tableView.hidden = false
            
            //Class in next 5 minutes
            if let time = self.timeUntilNextClass {
                if Int(time) < kCheckInTime {
                    self.shouldCheckIn = true
                    self.btnHere.hidden = false
                }
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
        return courses.count-coursesCompleted
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TodaysCourseTableViewCell
        
        let course = courses[indexPath.row+coursesCompleted]
        
        cell.titleLabel.text = course.title
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell.timeLabel.text = "\(dateFormatter.stringFromDate(convertDateToBaseDate(course.startsAt!))) - \(dateFormatter.stringFromDate(course.endsAt!))"
        
        cell.colorViewBGColor = UIColor(rgba: course.hexColor!)
        cell.colorView.backgroundColor = UIColor(rgba: course.hexColor!)
        
        print(convertDateToBaseDate(course.startsAt!))
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.row < courses.count {
            let course = courses[indexPath.row+coursesCompleted]
            
            let skip = UITableViewRowAction(style: .Default, title: "Skip", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.skip(course)
            })

            let imHere = UITableViewRowAction(style: .Normal, title: "I'm Here", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.checkIn(course)
            })

            let ti = NSInteger(convertDateToBaseDate(course.startsAt!).timeIntervalSinceDate(convertDateToBaseDate(NSDate())))
            let minutes = (ti / 60) % 60
            let hours = (ti / 3600)

            //print(hours, minutes)
            
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
            if self.shouldCheckIn {
                self.checkIn(courses[0])
                self.shouldCheckIn = false
            }
            
            manager.startMonitoringSignificantLocationChanges()
            locationStorage.updateLocation(location.coordinate)
        }
    }

}
