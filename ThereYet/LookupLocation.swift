//
//  LookupLocation.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/29/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import CoreLocation

class LookupLocation {
    
    var title: String?
    var address: String?
    var location: CLLocationCoordinate2D?
    
    init(title: String, address: String, location: CLLocationCoordinate2D) {
        self.title = title
        self.address = address
        self.location = location
    }
}