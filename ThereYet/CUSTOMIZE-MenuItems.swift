//
//  MenuItems.swift
//  AWSideBar
//
//  Created by Andrew Whitehead on 12/20/15.
//  Copyright © 2015 Andrew Whitehead. All rights reserved.
//

import UIKit

//TODO: fill in with data for specific project!

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
        if section == 0 {
            return [MenuItem(name: "Home", image: nil, highlightedImage: nil, color: UIColor.lightGrayColor(), action: .Navigation)]
        } else if section == 1 {
            return [MenuItem(name: "Show Schedule", image: nil, highlightedImage: nil, color: UIColor.blueColor(), action: .Selector),
                    MenuItem(name: "Show Login Data", image: nil, highlightedImage: nil, color: UIColor.greenColor(), action: .Selector),
                    MenuItem(name: "Sign Out", image: nil, highlightedImage: nil, color: UIColor.redColor(), action: .Selector),]
        } else {
            return []
        }
    }

}
