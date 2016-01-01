//
//  MenuItems.swift
//  AWSideBar
//
//  Created by Andrew Whitehead on 12/20/15.
//  Copyright © 2015 Andrew Whitehead. All rights reserved.
//

import UIKit

//TODO: customize -- fill in with your own data!

class MenuItems {

    static func numSections() -> Int {
        return 2
    }
    
    static func numRowsInSection() -> Array<Int> {
        return [1, 1]
    }
    
    static func sectionTitles() -> Array<String>? {
        //type empty string ("") to hide a specific header
        return ["", "Debug"]
    }
    
    static func indexPathForMenuItem(menuItem: MenuItem) -> NSIndexPath? {
        var indexPath: NSIndexPath? = nil
        for (var i = 0; i < numSections(); i++) {
            let menuItemSection = menuItems(i)
            for (var j = 0; j < numRowsInSection()[i]; j++) {
                if menuItem == menuItemSection[j] {
                    indexPath = NSIndexPath(forRow: j, inSection: i)
                }
            }
        }
        
        return indexPath
    }
    
    static func menuItems(section: Int) -> Array<MenuItem> {
        let mainColor = UIColor.mainBlueColor()
        
        if section == 0 {
            return [
                MenuItem(storyboardID: "HomeViewController", name: "Home", image: UIImage(named: "ic_side_home")?.imageWithRenderingMode(.AlwaysTemplate), highlightedImage: nil, color: mainColor, action: .Navigation),
                MenuItem(storyboardID: "OverviewViewController", name: "Overview", image: UIImage(named: "ic_side_overview")?.imageWithRenderingMode(.AlwaysTemplate), highlightedImage: nil, color: mainColor, action: .Navigation),
                MenuItem(storyboardID: "CoursesViewController", name: "My Classes", image: UIImage(named: "ic_side_courses")?.imageWithRenderingMode(.AlwaysTemplate), highlightedImage: nil, color: mainColor, action: .Navigation),
                MenuItem(storyboardID: "RewardsViewController", name: "My Rewards", image: UIImage(named: "ic_side_rewards")?.imageWithRenderingMode(.AlwaysTemplate), highlightedImage: nil, color: mainColor, action: .Navigation),
                MenuItem(storyboardID: "SettingsViewController", name: "Settings", image: UIImage(named: "ic_side_settings")?.imageWithRenderingMode(.AlwaysTemplate), highlightedImage: nil, color: mainColor, action: .Navigation)
            ]
        } else if section == 1 {
            return [MenuItem(storyboardID: nil, name: "Show Schedule", image: nil, highlightedImage: nil, color: UIColor.blueColor(), action: .Selector),
                MenuItem(storyboardID: nil, name: "Show Login Data", image: nil, highlightedImage: nil, color: UIColor.greenColor(), action: .Selector),
                MenuItem(storyboardID: nil, name: "Sign Out", image: nil, highlightedImage: nil, color: UIColor.redColor(), action: .Selector),]
        } else {
            return []
        }
    }

}
