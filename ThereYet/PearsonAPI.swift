//
//  PearsonAPI.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/19/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PearsonAPI {
    
    private static let url = "http://api.learningstudio.com/"
    private static let clientId = "99af8915-a27e-47d1-8b15-8e126e38c610"
    
    static func login(username: String, password: String, completion: ((success: Bool, error: NSError?) -> ())) {
        let params = [
            "client_id": self.clientId,
            "grant_type": "password",
            "username": "gbtestc\\\(username)",
            "password": password
        ]

        Alamofire.request(.POST, "\(self.url)token", parameters: params)
            .responseJSON { response in
                
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    let accessToken = json["access_token"].stringValue
                    let refreshToken = json["refresh_token"].stringValue
                    let expireToken = NSDate().dateByAddingTimeInterval(json["expires_in"].doubleValue)
                    
                    //Check if error occured
                    if json["access_token"].isExists() {
                        
                        //Store details
                        let auth = AuthData(accessToken: accessToken, refreshToken: refreshToken, expireDate: expireToken)
                        auth.store()
                        
                        completion(success: true, error: nil)
                        return
                    }
                }
                
                completion(success: false, error: NSError(domain: "UserAuth", code: 0, userInfo: ["error": "Invalid username/password"]))
                return
        }
        
        //TODO: Network error
    }
    
    static func refreshToken(auth: AuthData, completion: (() -> ())) {
        let params = [
            "client_id": self.clientId,
            "grant_type": "refresh_token",
            "refresh_token": auth.refreshToken!
        ]
        
        Alamofire.request(.POST, "\(self.url)token", parameters: params)
            .responseJSON { response in
                
                
        }
    }
    
    static func retreiveCourses(user: User, completion: ((courses: [Course]?) -> ())) {
        var courseIds:[Int] = []
        
        self.apiRequest(user, path: "courses", completion: {
            json in
            
            if let dataList = json?["courses"].array {
                for dataItem in dataList {
                    let dataPath = dataItem["links"][0]["href"].stringValue
                    if !dataPath.isEmpty {
                        let dataId = Int(NSURL(string: "dataId")!.pathComponents![1])
                        courseIds.append(dataId!)
                    }
                }
            }
            
            print(courseIds)
            
        })
    }
    
    private static func apiRequest(user: User, path: String, completion: ((json: JSON?) -> ())) {
        
        let headers = ["X-Authorization": "Access_Token access_token="]
        Alamofire.request(.GET, "\(self.url)\(url)", headers: headers)
            .responseJSON { response in
                
                if let data = response.result.value {
                    completion(json: JSON(data))
                    return
                }
                
                completion(json: nil)
        }
    }
    
}