//
//  SettingsViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 1/1/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import UIKit

import CoreData
import Parse

class SettingsViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.textLabel?.text = "Sign Out"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0 && indexPath.row == 0) {
                signOut()
        }
    }
    
    func signOut() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Course")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            print(results)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in Course error : \(error) \(error.userInfo)")
        }
        
        let pearsonUser = PearsonUser()
        pearsonUser.authData.destroy()
        pearsonUser.destroy()
        PFUser.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = loginVC
    }
    
}
