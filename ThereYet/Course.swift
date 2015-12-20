//
//  Course.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/18/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import CoreData

class Course: NSManagedObject {
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var instructor: String?
    @NSManaged var hexColor: String?
}
