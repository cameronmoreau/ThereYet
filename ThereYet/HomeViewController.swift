//
//  HomeViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/21/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData
import BLKFlexibleHeightBar
import Charts

class HomeViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
        //FIXME: incomplete
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //FIXME: incomplete
        return 2
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
    
//    func uhhh() -> BLKFlexibleHeightBar {
//        
//        //Top bar
//        let headerBar = BLKFlexibleHeightBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 100))
//        headerBar.minimumBarHeight = 50
//        headerBar.backgroundColor = UIColor.redColor()
//        headerBar.setNeedsLayout()
//        headerBar.layoutIfNeeded()
//        
//        
//        //Behavior
//        headerBar.behaviorDefiner = SquareCashStyleBehaviorDefiner()
//        self.tableView.delegate = headerBar.behaviorDefiner as? protocol<UITableViewDelegate>
//        
//        //Sub View
//        let label = UILabel()
//        label.text = "Hello world"
//        label.textColor = UIColor.whiteColor()
//        label.font = UIFont.systemFontOfSize(25)
//        label.sizeToFit()
//        headerBar.addSubview(label)
//        
//        //layout attrs
//        let initLayout = BLKFlexibleHeightBarSubviewLayoutAttributes()
//        initLayout.size = label.frame.size
//        initLayout.center = CGPointMake(CGRectGetMidX(headerBar.bounds), CGRectGetMidY(headerBar.bounds)+10.0)
//        label.addLayoutAttributes(initLayout, forProgress: 0)
//        
//        let finalLayout = BLKFlexibleHeightBarSubviewLayoutAttributes(existingLayoutAttributes: initLayout)
//        finalLayout.alpha = 0.0;
//        let translation = CGAffineTransformMakeTranslation(0.0, -30.0);
//        let scale = CGAffineTransformMakeScale(0.2, 0.2);
//        finalLayout.transform = CGAffineTransformConcat(scale, translation);
//        label.addLayoutAttributes(finalLayout, forProgress: 1.0)
//        
//        
//        return headerBar
//    }
    
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
