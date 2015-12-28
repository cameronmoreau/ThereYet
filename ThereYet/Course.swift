//
//  Course.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/23/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import Foundation
import CoreData


class Course: NSManagedObject {

    @NSManaged var pearson_id: NSNumber?
    @NSManaged var hexColor: String?
    @NSManaged var title: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var locationLat: NSNumber?
    @NSManaged var locationLng: NSNumber?
    @NSManaged var startsAt: NSDate?
    @NSManaged var endsAt: NSDate?
    @NSManaged var classDays: AnyObject?

}