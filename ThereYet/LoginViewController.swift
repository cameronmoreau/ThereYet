//
//  LoginViewController.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/18/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData
import JGProgressHUD

class LoginViewController: CenterViewController {
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    //Lol delete this later
    @IBAction func fuckItShipIt(sender: UIButton) {
        textFieldUsername.text = "cameron.cm6.student@gmail.com"
        textFieldPassword.text = "edGS2Opq"
    }
    
    @IBAction func btnLoginPressed(sender: UIButton) {
        
        //Attempt Login
        if formIsValid() {
            let loadingHUD = JGProgressHUD(style: .Dark)
            loadingHUD.textLabel.text = "Loading"
            
            loadingHUD.showInView(self.view, animated: true)
            
            //Login with pearson api
            PearsonAPI.login(textFieldUsername.text!, password: textFieldPassword.text!, completion: {
                (user: User?, error: NSError?) in
                
                if user != nil {
                    
                    //Retreive user's courses
                    PearsonAPI.retreiveCourses(user!, completion: {
                        courses in
                        
                        //Save all courses to core data
                        for course in courses {
                            do {
                                try course.managedObjectContext?.save()
                                print("Saving \(course.title!)")
                            } catch let error as NSError {
                                print(error)
                            }
                        }
                        
                        loadingHUD.dismiss()
                        
                        //Contineu to home page
                        let appDelegate = UIApplication.sharedApplication().delegate
                        let containerViewController = ContainerViewController(initialMenuItem: MenuItems.menuItems(0)[0])
                        appDelegate?.window??.rootViewController = containerViewController
                    })
                } else {
                    self.showBasicError(error!.userInfo["error"] as! String)
                }
            })
        }
            
            //Give error
        else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.draggable = false
        
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func formIsValid() -> Bool {
        if textFieldUsername.text!.isEmpty || textFieldPassword.text!.isEmpty {
            showBasicError("Username and password is required")
            return false
        }
        
        return true
    }
    
    func showBasicError(message: String) {
        let errorController = UIAlertController(title: "Login Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        errorController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(errorController, animated: true, completion: nil)
    }
}