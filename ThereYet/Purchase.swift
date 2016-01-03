//
//  Purchase.swift
//  ThereYet
//
//  Created by Cameron Moreau on 1/3/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import Parse

class Purchase {
    var item: [String:AnyObject]?
    var type: String?
    
    init(item: [String:AnyObject], type: String) {
        self.item = item
        self.type = type
    }
    
    func toString() -> String {
        if type == "offer" {
            return "\(item!["title"]!)"
        }
        
        return "\(item!["amount"]) gift card"
    }
}