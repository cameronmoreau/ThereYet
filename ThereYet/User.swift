//
//  User.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/18/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Alamofire
import SwiftyJSON

class User {
    
    static func login(username: String, password: String, completion: ((success: Bool, error: NSError?) -> ())) {
        let params = [
            "client_id": "99af8915-a27e-47d1-8b15-8e126e38c610",
            "grant_type": "password",
            "username": "gbtestc\\\(username)",
            "password": password
        ]
        
        Alamofire.request(.POST, "http://api.learningstudio.com/token", parameters: params)
            .responseJSON { response in
                
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    if json["access_token"].isExists() {
                        completion(success: true, error: nil)
                        return
                    }
                }
                
                completion(success: false, error: NSError(domain: "UserAuth", code: 0, userInfo: ["error": "Invalid username/password"]))
                return
        }
        
        //TODO: Network error
    }
    
}
