//
//  PearsonAPI.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/19/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import SwiftyJSON

class PearsonAPI {
    
    private static let url = "http://api.learningstudio.com/"
    private static let clientId = "99af8915-a27e-47d1-8b15-8e126e38c610"
    
    private enum AuthType {
        case Login
        case Refresh
    }
    
    static func login(username: String, password: String, completion: ((user: PearsonUser?, error: NSError?) -> ())) {
        let params = [
            "client_id": self.clientId,
            "grant_type": "password",
            "username": "gbtestc\\\(username)",
            "password": password
        ]

        authRequest(.Login, params: params, completion: {
            (auth, error) in
            
            if auth != nil {
                self.apiRequest(auth!, path: "/me", completion: {
                    json in
                    
                    if let data = json?["me"] {
                        let id = data["id"].intValue
                        let firstName = data["firstName"].stringValue
                        let lastName = data["lastName"].stringValue
                        let email = data["emailAddress"].stringValue
                        let username = data["userName"].stringValue
                        
                        let user = PearsonUser(id: id, firstName: firstName, lastName: lastName, username: username, email: email, auth: auth!)
                        user.save()
                        
                        return completion(user: user, error: error)
                    }
                })
            }
            
            else {
                return completion(user: nil, error: error)
            }
        })
    }
    
    static func refreshToken(auth: PearsonAuthData, completion: ((success: Bool, error: NSError?) -> ())) {
        let params = [
            "client_id": self.clientId,
            "grant_type": "refresh_token",
            "refresh_token": auth.refreshToken!
        ]
        
        print(params["refresh_token"])
        
        authRequest(.Refresh, params: params, completion: {
            (auth, error) in
            
            return completion(success: auth != nil, error: error)
        })
    }
    
    static func retreiveCourses(user: PearsonUser, completion: ((courses: [Course]) -> ())) {
        var courses: [Course] = []
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("Course", inManagedObjectContext: context)
        
        self.apiRequest(user.authData, path: "users/\(user.id!)/courses", completion: {
            json in
            
            if let dataList = json?["courses"].array {
                
                //Get all courses
                for dataItem in dataList {
                    let dataPath = dataItem["links"][0]["href"].stringValue
                    if !dataPath.isEmpty {
                        let course = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Course
                        course.pearson_id = Int(NSURL(string: "\(dataPath)")!.pathComponents![2])
                        course.createdAt = NSDate()
                        courses.append(course)
                    }
                }
                
                //Get all course details
                for (i, course) in courses.enumerate() {
                    self.apiRequest(user.authData, path: "courses/\(course.pearson_id!)", completion: {
                        json in
                        
                        if let courseData = json?["courses"][0] {
                            //Check for "API Sandbox Course for cameron.cm6 Moreau" error
                            var tempTitle = courseData["title"].stringValue
                            var tempTitleArray = tempTitle.componentsSeparatedByString("for")
                            
                            if tempTitleArray.count > 1 {
                                tempTitleArray.removeLast()
                                tempTitle = tempTitleArray.joinWithSeparator("")
                                tempTitle = String(tempTitle.characters.dropLast())
                            }
                            
                            course.title = tempTitle
                            
                            //Check for last
                            if i >= courses.count - 1 {
                                completion(courses: courses)
                            }
                        }
                        
                    })
                }
            }
            
            
        })
    }
    
    private static func authRequest(type: AuthType, params: [String: AnyObject]?,
        completion: ((auth: PearsonAuthData?, error: NSError?) -> ())) {
            
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
                            let auth = PearsonAuthData(accessToken: accessToken, refreshToken: refreshToken, expireDate: expireToken)
                            auth.store()
                            
                            completion(auth: auth, error: nil)
                            return
                        }
                    }
                    
                    if type == .Login {
                        completion(auth: nil, error: NSError(domain: "UserAuth", code: 0, userInfo: ["error": "Invalid username/password"]))
                    } else {
                        completion(auth: nil, error: NSError(domain: "UserAuth", code: 0, userInfo: ["error": "Could not validate a key"]))
                    }
            }
            
            //TODO: Network error
    }
    
    private static func apiRequest(auth: PearsonAuthData, path: String, completion: ((json: JSON?) -> ())) {
        let headers = [
            "X-Authorization": "Access_Token access_token=\(auth.accessToken!)"
        ]
        
        Alamofire.request(.GET, "\(self.url)\(path)", headers: headers)
            .responseJSON { response in
                
                if let data = response.result.value {
                    completion(json: JSON(data))
                    return
                }
                
                completion(json: nil)
        }
    }
    
}