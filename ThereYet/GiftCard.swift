//
//  GiftCard.swift
//  ThereYet
//
//  Created by Cameron Moreau on 1/2/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import Parse

class GiftCard {
    
    var sponsor: PFObject?
    var amount: Int?
    var points: Int?
    
    init(sponsor: PFObject, object: [String: AnyObject]) {
        self.sponsor = sponsor
        self.amount = object["amount"] as? Int
        self.points = object["points"] as? Int
    }
}
