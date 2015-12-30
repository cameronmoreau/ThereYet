//
//  MapboxAPI.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/29/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Alamofire
import SwiftyJSON
import CoreLocation

class MapboxAPI {
    
    private static let accessToken = "pk.eyJ1IjoidXRhLW1vYmkiLCJhIjoiY2lpcXZ4aXlpMDJmdnZxbTVvMG5odXIxZiJ9.91UEUAkG4XyGbId_EnEB1g"
    
    static func geocodeLookup(query: String, completion: ((location: LookupLocation?) -> ())) {
        let paramQuery = self.generateQuery(query)
        let url = "https://api.mapbox.com/geocoding/v5/mapbox.places/\(paramQuery).json?access_token=\(self.accessToken)"
        
        Alamofire.request(.GET, url).responseJSON { response in
            
            if let data = response.result.value {
                let json = JSON(data)
                
                let locations = json["features"].array
                if(locations?.count > 0) {
                    let loc = locations![0]
                    let title = loc["text"].stringValue
                    let address = loc["place_name"].stringValue
                    let coord = CLLocationCoordinate2DMake(loc["center"][1].doubleValue, loc["center"][0].doubleValue)
                    
                    completion(location: LookupLocation(title: title, address: address, location: coord))
                    return
                }
            }
            
            completion(location: nil)
        }
    }
    
    private static func generateQuery(query: String) -> String {
        let toArray = query.componentsSeparatedByString(" ")
        return toArray.joinWithSeparator("+")
    }

}