//
//  Location+CoreDataProperties.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/15/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var run: Run?

}
