//
//  CenterViewController.swift
//  AWSideBar
//
//  Created by Andrew Whitehead on 12/20/15.
//  Copyright © 2015 Andrew Whitehead. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate {
    optional func toggleSidePanel()
    optional func collapseSidePanel()
}

class CenterViewController: UIViewController, SideViewControllerDelegate {
    
    var delegate: CenterViewControllerDelegate?
    
    var containerViewController: ContainerViewController!
    
    var color: UIColor! {
        didSet {
            navigationController?.navigationBar.barTintColor = color
        }
    }
    
    var draggable = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if color == nil {
            color = UIColor.lightGrayColor()
        }
        
        self.navigationController?.navigationBar.barStyle = .Black
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: self, action: Selector("menuButtonTapped:"))
        menuButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = menuButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.collapseSidePanel!()
    }
    
    func menuButtonTapped(sender: AnyObject?) {
        delegate?.toggleSidePanel?()
    }
    
    func menuItemSelected(menuItem: MenuItem) {
        switch menuItem.action {
        case .Navigation:
            navigateToViewController(menuItem)
            break
        case .Selector:
            performAction(menuItem)
            break
        }
        
        delegate?.collapseSidePanel!()
    }
    
    func navigateToViewController(menuItem: MenuItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier(menuItem.name) //FIXME: will crash if the storyboardID doesn't exist!
       
        self.navigationController?.popViewControllerAnimated(false)
        
        var newCenterViewController: CenterViewController!
        if vc.isKindOfClass(UINavigationController) {
            let navController = vc as? UINavigationController
            newCenterViewController = navController?.viewControllers[0] as? CenterViewController
        } else {
            newCenterViewController = vc as? CenterViewController
        }
        newCenterViewController.delegate = containerViewController
        newCenterViewController.containerViewController = containerViewController
        newCenterViewController.title = menuItem.name
        containerViewController.centerViewController = newCenterViewController
        
        self.navigationController?.pushViewController(newCenterViewController, animated: false)
        
        newCenterViewController.color = menuItem.color //must put this after push because navigation bar isn't there before it's pushed
    }
    
    func performAction(menuItem: MenuItem) {
        switch menuItem.name {
            //TODO: make cases for each menu item action
            default:
                print("\(menuItem.name)")
                break
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

}
