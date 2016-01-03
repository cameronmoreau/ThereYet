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
import Parse

class LoginViewController: CenterViewController, UITextFieldDelegate {
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    
    //Lol delete this later
    @IBAction func fuckItShipIt(sender: UIButton) {
        textFieldUsername.text = "cameron.cm6.student@gmail.com"
        textFieldPassword.text = "edGS2Opq"
    }
    
    @IBAction func btnLoginPressed(sender: UIButton?) {
        
        //Attempt Login
        if formIsValid() {
            let email = textFieldUsername.text!
            let password = textFieldPassword.text!
            
            let loadingHUD = JGProgressHUD(style: .Dark)
            loadingHUD.textLabel.text = "Logging in"
            loadingHUD.showInView(self.view, animated: true)
            
            //Do a basic parse login
            PFUser.logInWithUsernameInBackground(email, password: password, block: {
                (parseUser: PFUser?, error: NSError?) in
                
                //User was found, check if associated to parse
                if parseUser != nil {
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setInteger(parseUser!["points"] as! Int, forKey: "points")
                    defaults.synchronize()
                    
                    //User does not have a Pearson account
                    if parseUser!["pearsonAuthData"] == nil {
                        loadingHUD.dismiss()
                        self.continueToHome()
                    }
                }
                
                //Check for Pearson account
                PearsonAPI.login(email, password: password, completion: {
                    (pearsonUser: PearsonUser?, error: NSError?) in
                    
                    //Pearson account was found
                    if pearsonUser != nil {
                        loadingHUD.textLabel.text = "Getting details from Pearson"
                        
                        //Parse AND pearson account - do update
                        if parseUser != nil {
                            PearsonAPI.retreiveCourses(pearsonUser!, completion: {
                                courses in
                                
                                SyncManager.runInitalSync(courses, completion: {
                                    (courses: [Course_RegularObject]) in
                                    
                                    var saved = [Course]()
                                    
                                    //Save each new course
                                    for c in courses {
                                        saved.append(c.saveAsNSManagedObject()!)
                                    }
                                    
                                    //Download from parse
                                    SyncManager.fullDownload({
                                        (success: Bool) in
                                        
                                        //Upload new to parse
                                        SyncManager.fullUpload(courses, saved: saved, completion: {
                                            (success: Bool) in
                                            
                                            //FINALY DONE!
                                            loadingHUD.dismiss()
                                            self.continueToHome()
                                        })
                                    })
                                    
                                })
                            })
                        }
                        
                        //Pearson - Register account
                        else {
                            
                            //Create parse account with details
                            let parseUser = PFUser()
                            parseUser.email = email
                            parseUser.username = email
                            parseUser.password = password
                            parseUser["pearsonAuthData"] = pearsonUser!.authDataToObject()
                            parseUser["points"] = 0
                            
                            parseUser.signUpInBackgroundWithBlock({
                                (success: Bool, error: NSError?) in
                                
                                //Parse account was created, fetch final details
                                if success {
                                    loadingHUD.textLabel.text = "Getting details from Pearson"
                                    
                                    //Retreive user's courses
                                    PearsonAPI.retreiveCourses(pearsonUser!, completion: {
                                        courses in
                                        
                                        for c in courses {
                                            c.saveAsNSManagedObject()
                                        }
                                        
                                        //Finally done
                                        loadingHUD.dismiss()
                                        self.continueToHome()
                                    })
                                }
                                    
                                //Failed to create parse account
                                else {
                                    loadingHUD.dismiss()
                                    print(error)
                                    self.showBasicError("Login", message: "Error migrating Pearson account")
                                }
                            })
                        }
                    }
                        
                    //No Pearson account
                    else {
                        loadingHUD.dismiss()
                        
                        if parseUser != nil {
                            self.continueToHome()
                        }
                        
                        //No account anywhere
                        else {
                            self.showBasicError("Login", message: "Invalid email/password")
                        }
                    }
                })
                //print(error["message"])
            })
            
            //            //Login with pearson api
            //            PearsonAPI.login(textFieldUsername.text!, password: textFieldPassword.text!, completion: {
            //                (user: User?, error: NSError?) in
            //
            //                if user != nil {
            //
            //                    //Retreive user's courses
            //                    PearsonAPI.retreiveCourses(user!, completion: {
            //                        courses in
            //
            //                        //Save all courses to core data
            //                        for course in courses {
            //                            do {
            //                                try course.managedObjectContext?.save()
            //                                print("Saving \(course.title!)")
            //                            } catch let error as NSError {
            //                                print(error)
            //                            }
            //                        }
            //
            //                        loadingHUD.dismiss()
            //
            //                        //Contineu to home page
            //                        let appDelegate = UIApplication.sharedApplication().delegate
            //                        let containerViewController = ContainerViewController(initialMenuItem: MenuItems.menuItems(0)[0])
            //                        appDelegate?.window??.rootViewController = containerViewController
            //                    })
            //                } else {
            //                    loadingHUD.dismiss()
            //                    self.showBasicError("Login", message: error!.userInfo["error"] as! String)
            //                }
            //            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true
        self.draggable = false
        self.textFieldUsername.delegate = self
        self.textFieldPassword.delegate = self
        
        //Tap anywhere to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func formIsValid() -> Bool {
        if textFieldUsername.text!.isEmpty || textFieldPassword.text!.isEmpty {
            self.showBasicError("Login", message: "Username and password is required")
            return false
        }
        
        return true
    }
    
    func continueToHome() {
        let appDelegate = UIApplication.sharedApplication().delegate
        let containerViewController = ContainerViewController(initialMenuItem: MenuItems.menuItems(0)[0])
        appDelegate?.window??.rootViewController = containerViewController
    }
    
    //MARK: - Keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //logoImage.frame = CGRectMake(logoImage.frame.origin.x, logoImage.frame.origin.x, logoImage.frame.width, 0)
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch(textField) {
        case textFieldUsername:
            textFieldPassword.becomeFirstResponder()
            return true
            
        case textFieldPassword:
            btnLoginPressed(nil)
            return true
            
        default:
            return true
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}