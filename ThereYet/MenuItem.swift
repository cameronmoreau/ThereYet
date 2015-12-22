//
//  MenuItem.swift
//  AWSideBar
//
//  Created by Andrew Whitehead on 12/20/15.
//  Copyright © 2015 Andrew Whitehead. All rights reserved.
//

import UIKit

enum MenuItemActionType {
    case Selector
    case Navigation
}


public class MenuItem: Equatable {
    
    let name: String
    let color: UIColor
    
    let image: UIImage?
    let highlightedImage: UIImage?
    
    let action: MenuItemActionType
    
    init() {
        self.name = "Title"
        self.color = UIColor.lightGrayColor()
        
        self.image = nil
        self.highlightedImage = nil
        
        self.action = .Selector
    }
    
    init(name: String, image: UIImage?, highlightedImage: UIImage?, color: UIColor, action: MenuItemActionType) {
        self.name = name
        self.color = color
        
        self.image = image
        self.highlightedImage = highlightedImage
        
        self.action = action
    }
    
    init(name: String, color: UIColor, action: MenuItemActionType) {
        self.name = name
        self.color = color
        
        self.image = nil
        self.highlightedImage = nil
        
        self.action = action
    }

}

public func ==(lhs: MenuItem, rhs: MenuItem) -> Bool {
    return
        (lhs.name == rhs.name &&
            lhs.color == rhs.color &&
            lhs.image == rhs.image &&
            lhs.highlightedImage == rhs.highlightedImage &&
            lhs.action == rhs.action)
}
