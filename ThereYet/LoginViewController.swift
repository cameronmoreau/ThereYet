//
//  LoginViewController.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/18/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import PKHUD

class LoginViewController: UIViewController {
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
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
            
            PearsonAPI.login(textFieldUsername.text!, password: textFieldPassword.text!, completion: {
                (success: Bool, error: NSError?) in
                
                PKHUD.sharedHUD.hide()
                
                if success {
                    self.performSegueWithIdentifier("loginSegue", sender: self)
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