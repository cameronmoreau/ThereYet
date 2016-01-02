//
//  ContainerViewController.swift
//  AWSideBar
//
//  Created by Andrew Whitehead on 12/20/15.
//  Copyright © 2015 Andrew Whitehead. All rights reserved.
//

import UIKit

enum SlideOutState {
    case Collapsed
    case Expanded
}

class ContainerViewController: UIViewController, UIGestureRecognizerDelegate, CenterViewControllerDelegate {
    
    let kCenterViewControllerExpandedOffset: CGFloat = UIScreen.mainScreen().bounds.size.width*0.4
    
    var kAnimationDuration: NSTimeInterval = 0.5
    var kSpringDampingRatio: CGFloat = 1.0
    
    var sidePanelShadowShouldShow = true
    var sidePanelShadowOpacity: Float = 0.5
    
    var sidePanelRowHeight: CGFloat = 44
    var sidePanelHeaderHeight: CGFloat = 22
    var sidePanelCustomHeaderView: UIView!
    
    var currentState: SlideOutState = .Collapsed {
        didSet {
            let shouldShowShadow = currentState != .Collapsed
            showShadowForCenterViewController(shouldShowShadow)
            
            if currentState == .Collapsed {
                centerViewController.view.userInteractionEnabled = true
            } else {
                centerViewController.view.userInteractionEnabled = false
            }
        }
    }
    var sideViewController: SideViewController?
    
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!
    
    var initialMenuItem: MenuItem!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    required init(initialMenuItem: MenuItem) {
        super.init(nibName: nil, bundle: nil)
        
        self.initialMenuItem = initialMenuItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var vc = storyboard.instantiateViewControllerWithIdentifier(initialMenuItem.storyboardID!) //FIXME: will crash if the storyboardID doesn't exist!
        if vc.isKindOfClass(UINavigationController) {
            let navController = vc as! UINavigationController
            vc = navController.viewControllers[0]
        }
        centerViewController = vc as! CenterViewController
        centerViewController.delegate = self
        centerViewController.containerViewController = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
        centerViewController.color = initialMenuItem.color
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
        panGestureRecognizer.minimumNumberOfTouches = 1
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.isKindOfClass(UISwipeGestureRecognizer)  {
            return false
        } else {
            return true
        }
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if centerNavigationController.viewControllers.count <= 2 && centerViewController.draggable {
            let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
            
            switch recognizer.state {
            case .Began:
                if (currentState == .Collapsed) {
                    if gestureIsDraggingFromLeftToRight {
                        addSideViewController()
                    }
                    
                    showShadowForCenterViewController(sidePanelShadowShouldShow)
                }
            case .Changed:
                if (sideViewController != nil && recognizer.view!.center.x + recognizer.translationInView(view).x >= view.bounds.size.width*0.5 && recognizer.view!.frame.origin.x + recognizer.translationInView(view).x <= UIScreen.mainScreen().bounds.size.width-kCenterViewControllerExpandedOffset) { //prevents overflow from the other side
                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                }
                recognizer.setTranslation(CGPointZero, inView: view)
            case .Ended:
                if (sideViewController != nil) {
                    //animate the side panel open or closed based on whether the view has moved more or less than halfway
                    let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                    animateSidePanel(shouldExpand: hasMovedGreaterThanHalfway)
                }
            default:
                break
            }
        }
    }
    
    func collapseSidePanel() {
        switch (currentState) {
            case .Expanded:
                toggleSidePanel()
            default:
            break
        }
    }
    
    func toggleSidePanel() {
        let notAlreadyExpanded = (currentState != .Expanded)
        
        if notAlreadyExpanded {
            addSideViewController()
        }
        
        animateSidePanel(shouldExpand: notAlreadyExpanded)
    }
    
    func animateSidePanel(shouldExpand shouldExpand: Bool) {
        if shouldExpand {
            currentState = .Expanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - kCenterViewControllerExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed
            }
        }
    }
    
    func addSideViewController() {
        if (sideViewController == nil) {
            let storyboard = UIStoryboard(name: "SideViewController", bundle: NSBundle.mainBundle())
            sideViewController = storyboard.instantiateViewControllerWithIdentifier("SideViewController") as? SideViewController //FIXME: will crash if the storyboardID doesn't exist!
            sideViewController!.selectedMenuItem = initialMenuItem
            
            addChildSideViewController(sideViewController!)
            
            sideViewController?.tableView.selectRowAtIndexPath(MenuItems.indexPathForMenuItem(initialMenuItem), animated: false, scrollPosition: .Top)
        }
    }
    
    func addChildSideViewController(sideViewController: SideViewController) {
        sideViewController.delegate = centerViewController
        
        view.insertSubview(sideViewController.view, atIndex: 0)
        
        addChildViewController(sideViewController)
        sideViewController.didMoveToParentViewController(self)
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(kAnimationDuration, delay: 0, usingSpringWithDamping: kSpringDampingRatio, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerNavigationController.view.layer.shadowOpacity = sidePanelShadowOpacity
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }

}
