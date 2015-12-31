//
//  AuthData.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/20/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

class PearsonAuthData {
    
    var accessToken: String?
    var refreshToken: String?
    var expireDate: NSDate?
    
    private let KEY_ACCESS_TOKEN = "accessToken"
    private let KEY_REFRESH_TOKEN = "refreshToken"
    private let KEY_EXPIRE_DATE = "expireDate"
    
    init() {
        loadAuthData()
    }
    
    init(accessToken: String, refreshToken: String, expireDate: NSDate) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expireDate = expireDate
    }
    
    private func loadAuthData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.accessToken = defaults.stringForKey(KEY_ACCESS_TOKEN)
        self.refreshToken = defaults.stringForKey(KEY_REFRESH_TOKEN)
        self.expireDate = defaults.objectForKey(KEY_EXPIRE_DATE) as? NSDate
    }
    
    func store() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(accessToken, forKey: KEY_ACCESS_TOKEN)
        defaults.setObject(refreshToken, forKey: KEY_REFRESH_TOKEN)
        defaults.setObject(expireDate, forKey: KEY_EXPIRE_DATE)
        defaults.synchronize()
    }
    
    func destroy() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: KEY_ACCESS_TOKEN)
        defaults.setObject(nil, forKey: KEY_REFRESH_TOKEN)
        defaults.setObject(nil, forKey: KEY_EXPIRE_DATE)
        defaults.synchronize()
    }
    
    func toDictionary() -> [String:AnyObject] {
        return [
            KEY_ACCESS_TOKEN: self.accessToken!,
            KEY_REFRESH_TOKEN: self.refreshToken!,
            KEY_EXPIRE_DATE: self.expireDate!
        ]
    }
    
    func isExpired() -> Bool {
        if let date = expireDate {
            if NSDate().timeIntervalSince1970 < date.timeIntervalSince1970 {
                return false
            }
        }
        
        return true
    }
    
    func hasData() -> Bool {
        if accessToken != nil && refreshToken != nil && expireDate != nil {
            return true
        }
        
        return false
    }
}