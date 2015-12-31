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
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var progressImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var labelTodaysClasses: UILabel!
    @IBOutlet weak var labelCountDown: UILabel!
    
    let pearsonUser = PearsonUser()
    let locationManager = CLLocationManager()
    let locationStorage = LocationStorage()
    
    var courses: [Course]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Temp push notification
//        let justInformAction = UIMutableUserNotificationAction()
//        justInformAction.identifier = "justInform"
//        justInformAction.title = "OK, got it"
//        justInformAction.activationMode = UIUserNotificationActivationMode.Background
//        justInformAction.destructive = false
//        justInformAction.authenticationRequired = false
//        
//        let modifyListAction = UIMutableUserNotificationAction()
//        modifyListAction.identifier = "editList"
//        modifyListAction.title = "Edit list"
//        modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
//        modifyListAction.destructive = false
//        modifyListAction.authenticationRequired = true
//        
//        let trashAction = UIMutableUserNotificationAction()
//        trashAction.identifier = "trashAction"
//        trashAction.title = "Delete list"
//        trashAction.activationMode = UIUserNotificationActivationMode.Background
//        trashAction.destructive = true
//        trashAction.authenticationRequired = true
//        
//        let shoppingListReminderCategory = UIMutableUserNotificationCategory()
//        shoppingListReminderCategory.identifier = "shoppingListReminderCategory"
//        shoppingListReminderCategory.setActions([justInformAction, modifyListAction, trashAction], forContext: UIUserNotificationActionContext.Default)
//        shoppingListReminderCategory.setActions([justInformAction], forContext: UIUserNotificationActionContext.Minimal)
//        
//        let categories = Set<UIUserNotificationCategory>(arrayLiteral: restartGameCategory)
//        
//        
//        let newNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: (NSSet(array: [shoppingListReminderCategory])) as? Set<UIUserNotificationCategory>))
        //UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        
//        let endGameAction = UIMutableUserNotificationAction()
//        endGameAction.identifier = "END_GAME"
//        endGameAction.title = "End Game"
//        endGameAction.activationMode = .Background
//        endGameAction.authenticationRequired = false
//        endGameAction.destructive = true
//        
//        let continueGameAction = UIMutableUserNotificationAction()
//        continueGameAction.identifier = "CONTINUE_GAME"
//        continueGameAction.title = "Continue"
//        continueGameAction.activationMode = .Foreground
//        continueGameAction.authenticationRequired = false
//        continueGameAction.destructive = false
//        
//        let restartGameCategory = UIMutableUserNotificationCategory()
//        restartGameCategory.identifier = "RESTART_CATEGORY"
//        restartGameCategory.setActions([continueGameAction, endGameAction], forContext: .Default)
//        restartGameCategory.setActions([endGameAction, continueGameAction], forContext: .Minimal)
//        
//        let categories = Set<UIUserNotificationCategory>(arrayLiteral: restartGameCategory)
//        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
//        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        var localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
        localNotification.alertBody = "new Blog Posted at iOScreator.com"
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //Location data
        
        if !CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
//            self.locationManager.delegate = self
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            self.locationManager.startUpdatingLocation()
        }
        
        //Table
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let weekdayInt = NSCalendar.currentCalendar().components(.Weekday, fromDate: NSDate()).weekday-1
        let weekday = "\(weekdayInt)"
        
        courses  = [Course]()
        let fetchRequest = NSFetchRequest(entityName: "Course")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "classDays CONTAINS[cd] %@", weekday), NSPredicate(format: "startsAt > %@", NSDate())])
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try courses = context.executeFetchRequest(fetchRequest) as! [Course]
        } catch let error as NSError {
            print(error)
        }
        
        fixUIForClasses()
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(5, 0, 0, 0)
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        let time: NSTimeInterval = 1
        self.progressBar.setValue(100, animateWithDuration: time)
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fixUIForClasses() {
        if courses.count == 0 {
            self.tableView.hidden = true
            self.labelTodaysClasses.hidden = true
            self.labelCountDown.text = "15 points earned"
            self.labelHeading.text = "You're all done for today!"
            
            
            self.labelHeading.sizeToFit()
            self.labelCountDown.sizeToFit()
        } else {
            self.tableView.hidden = false
            
            let nextDate = courses[0].startsAt!
            let currentDate = NSDate()
            
            let time = nextDate.timeIntervalSinceDate(currentDate)
            self.labelCountDown.text = clockText(time)
            
            print(time)
        }
    }
    
    func clockText(interval: NSTimeInterval) -> String {
        let ti = NSInteger(interval)
        var output = ""
        
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if hours > 0 {
            output += String(format: "%d Hours ", arguments: [hours])
        }
        
        return output + String(format: "%d Minutes", arguments: [minutes])
        
        //return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes)
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
        cell.timeLabel.text = "\(dateFormatter.stringFromDate(course.startsAt!)) - \(dateFormatter.stringFromDate(course.endsAt!))"
        
        cell.colorViewBGColor = UIColor(rgba: course.hexColor!)
        cell.colorView.backgroundColor = UIColor(rgba: course.hexColor!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let skip = UITableViewRowAction(style: .Normal, title: "Skip", handler: {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            
        })
        
        return [skip]
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
    
    // MARK: - Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //If a location was found, store it
        if let location = manager.location {
            manager.startMonitoringSignificantLocationChanges()
            locationStorage.updateLocation(location.coordinate)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
