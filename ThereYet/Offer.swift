//
//  Offer.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/24/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Parse

class Offer: PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Offer"
    }
    
    @NSManaged var title: String!
    @NSManaged var desc: String!
    @NSManaged var company: String!
    @NSManaged var points: NSNumber!

}
