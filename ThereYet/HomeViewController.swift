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
import Charts
import MBCircularProgressBar

class HomeViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var progressImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    let locationManager = CLLocationManager()
    let locationStorage = LocationStorage()
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    let tempCoursesCount = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.user = User()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //Location data
        print(CLLocationManager.locationServicesEnabled())
        
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
        
        //Hide courses if done
        if tempCoursesCount == 0 {
            self.tableView.hidden = true
        }
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
    
    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempCoursesCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        //TODO: configure cell
        
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
                user.authData.destroy()
                user.destroy()
                
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
