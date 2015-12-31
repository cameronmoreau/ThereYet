//
//  User.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/18/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Alamofire
import SwiftyJSON

class PearsonUser {
    
    let authData: PearsonAuthData!
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var username: String?
    
    private let KEY_ID = "userId"
    private let KEY_FIRST_NAME = "userFirstName"
    private let KEY_LAST_NAME = "userLastName"
    private let KEY_EMAIL = "userEmail"
    private let KEY_USERNAME = "username"
    
    init() {
        self.authData = PearsonAuthData()
        loadData()
    }
    
    init(id: Int, firstName: String, lastName: String, username: String, email: String, auth: PearsonAuthData) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.authData = auth
    }
    
    func isLoggedIn() -> Bool {
        if authData.hasData() && !authData.isExpired() && id != nil {
            return true
        }
        
        return false
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(id, forKey: KEY_ID)
        defaults.setObject(firstName, forKey: KEY_FIRST_NAME)
        defaults.setObject(lastName, forKey: KEY_LAST_NAME)
        defaults.setObject(username, forKey: KEY_USERNAME)
        defaults.setObject(email, forKey: KEY_EMAIL)
        defaults.synchronize()
    }
    
    func destroy() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: KEY_ID)
        defaults.setObject(nil, forKey: KEY_FIRST_NAME)
        defaults.setObject(nil, forKey: KEY_LAST_NAME)
        defaults.setObject(nil, forKey: KEY_USERNAME)
        defaults.setObject(nil, forKey: KEY_EMAIL)
        defaults.synchronize()
    }
    
    func authDataToObject() -> [String:AnyObject] {
        var obj = self.authData!.toDictionary()
        obj["id"] = self.id!
        return obj
    }
    
    private func loadData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.id = defaults.integerForKey(KEY_ID)
        self.firstName = defaults.stringForKey(KEY_FIRST_NAME)
        self.lastName = defaults.stringForKey(KEY_LAST_NAME)
        self.username = defaults.stringForKey(KEY_USERNAME)
        self.email = defaults.stringForKey(KEY_EMAIL)
    }
    
}
