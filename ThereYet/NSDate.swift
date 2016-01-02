//
//  NSDate.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/30/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

extension NSDate {
    
    func stripTime() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let calComps = cal.components([.Month, .Day, .Year], fromDate: self)
        
        let base = NSDateComponents()
        base.year = calComps.year
        base.month = calComps.month
        base.day = calComps.day
        
        return cal.dateFromComponents(base)!
    }
    
    func convertToBaseDate() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let calComps = cal.components([.Hour, .Minute], fromDate: self)
        
        let base = NSDateComponents()
        base.minute = calComps.minute
        base.hour = calComps.hour
        
        return cal.dateFromComponents(base)!
    }
}