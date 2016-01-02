//
//  Offer.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/24/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Parse

class Offer {
    
    var sponsor: PFObject?
    var title: String?
    var points: Int?
    
    init(sponsor: PFObject, object: [String: AnyObject]) {
        self.sponsor = sponsor
        self.title = object["title"] as? String
        self.points = object["points"] as? Int
    }

}
