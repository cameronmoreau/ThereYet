//
//  CreateAccountViewController.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/30/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    
    var fields: [UITextField]!
    
    @IBAction func createAccountPressed(sender: UIButton?) {
        self.view.resignFirstResponder()
        
        if(formIsValid()) {
            let loadingHUD = JGProgressHUD(style: .Dark)
            loadingHUD.textLabel.text = "Registering"
            loadingHUD.showInView(self.view, animated: true)
            
            let user = PFUser()
            user.username = textFieldEmail.text
            user.email = textFieldEmail.text
            user.password = textFieldPassword.text
            user["name"] = textFieldName.text
            
            user.signUpInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) in
                
                loadingHUD.dismiss()
                
                if succeeded {
                    //Continue to home page
                    let appDelegate = UIApplication.sharedApplication().delegate
                    let containerViewController = ContainerViewController(initialMenuItem: MenuItems.menuItems(0)[0])
                    appDelegate?.window??.rootViewController = containerViewController
                } else {
                    if error?.code == 202 {
                        self.showBasicError("Register", message: "Looks like that email is already in use")
                    } else {
                        self.showBasicError("Register", message: "Error creating account")
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is just passed by reference
        fields = [textFieldName, textFieldEmail, textFieldPassword, textFieldConfirmPassword]
        for f in fields {
            f.delegate = self
        }
    }
    
    override func viewWillAppear(animated: Bool) {
//                navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//                navigationController?.navigationBar.shadowImage = UIImage()
//                navigationController?.navigationBar.translucent = true
//                navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
//                navigationController?.view.backgroundColor = UIColor.clearColor()
        
        self.textFieldName.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func formIsValid() -> Bool {
        
        //Check if emtpy
        for f in fields {
            if f.text!.isEmpty {
                self.showBasicError("Register", message: "All fields are required")
                return false
            }
        }
        
        if(textFieldPassword.text != textFieldConfirmPassword.text) {
            self.showBasicError("Register", message: "Passwords must match")
            return false
        }
        else if(textFieldPassword.text!.characters.count < 4) {
            self.showBasicError("Register", message: "Password must be 4 or more characters")
            return false
        }
        
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    //MARK: - Keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let i = fields.indexOf(textField) {
            if i == fields.count - 1 {
                createAccountPressed(nil)
            } else {
                fields[i + 1].becomeFirstResponder()
            }
        }
        
        return true
    }
    
}
