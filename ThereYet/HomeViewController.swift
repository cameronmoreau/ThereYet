//
//  HomeViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/21/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

class HomeViewController: CenterViewController {
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        user = User()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                user.authData.destroy()
                user.destroy()
                
                self.navigateToViewController(MenuItem(name: "LoginViewController", color: UIColor.lightGrayColor(), action: .Navigation))
                break
            
            case "Show Schedule":
                PearsonAPI.retreiveCourses(user, completion: {
                    courses in
                    
                    for course in courses {
                        print("\(course.title) \(course.id)")
                    }
                })
                break
            default:
                break
        }
    }

}
