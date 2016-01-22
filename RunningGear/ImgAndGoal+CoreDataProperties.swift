//
//  ImgAndGoal+CoreDataProperties.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/22/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ImgAndGoal {

    @NSManaged var imgUrl: String?
    @NSManaged var index: NSNumber?
    @NSManaged var isCompleteGoal: NSNumber?

}
