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
                
                //var hasAuth = false
                
                //User was found, continue login as normal
                if parseUser != nil {
                    loadingHUD.dismiss()
                    self.continueToHome()
                }
                    
                    //Check for Pearson account
                else {
                    PearsonAPI.login(email, password: password, completion: {
                        (pearsonUser: PearsonUser?, error: NSError?) in
                        
                        //Pearson account was found
                        if pearsonUser != nil {
                            
                            //Create parse account with details
                            let parseUser = PFUser()
                            parseUser.email = email
                            parseUser.username = email
                            parseUser.password = password
                            parseUser["pearsonAuthData"] = pearsonUser!.authDataToObject()
                            
                            parseUser.signUpInBackgroundWithBlock({
                                (success: Bool, error: NSError?) in
                                
                                //Parse account was created, fetch final details
                                if success {
                                    loadingHUD.textLabel.text = "Getting details from Pearson"
                                    
                                    //Retreive user's courses
                                    PearsonAPI.retreiveCourses(pearsonUser!, completion: {
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
                            
                            //No account anywhere sorry yo
                        else {
                            loadingHUD.dismiss()
                            self.showBasicError("Login", message: "Invalid email/password")
                        }
                    })
                }
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
            
            //Give error
        else {
            
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