//
//  UIViewController.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/29/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showBasicError(type: String, message: String) {
        let errorController = UIAlertController(title: "\(type) Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        errorController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(errorController, animated: true, completion: nil)
    }
    
}
