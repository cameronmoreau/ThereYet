//
//  LocationStorage.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/29/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import CoreLocation

class LocationStorage {
    
    var location: CLLocationCoordinate2D?
    var lastDate: NSDate?
    
    private let KEY_LAST_LAT = "lastLocation"
    private let KEY_LAST_LNG = "lastLocationLng"
    private let KEY_LAST_DATE = "lastLocationDate"
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let lat = defaults.objectForKey(KEY_LAST_LAT)
        let lng = defaults.objectForKey(KEY_LAST_LNG)
        
        if lat != nil && lng != nil {
            self.location = CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lng as! CLLocationDegrees)
        }
        
        
        self.lastDate = defaults.objectForKey(KEY_LAST_LNG) as? NSDate
    }
    
    func updateLocation(location: CLLocationCoordinate2D) {
        self.location = location
        self.lastDate = NSDate()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.location!.latitude, forKey: KEY_LAST_LAT)
        defaults.setObject(self.location!.longitude, forKey: KEY_LAST_LNG)
        defaults.setObject(self.lastDate!, forKey: KEY_LAST_DATE)
        defaults.synchronize()
    }
}