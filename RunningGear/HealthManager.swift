//
//  HealthManager.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/30/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    let healthKitStore:HKHealthStore = HKHealthStore()
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        
        // 1. Set the types you want to share from HK Store
        let shareTypes : Set = [HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
            HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            HKSampleType.workoutType()
        ]
        
        // 2. Set the types you want to read to HK Store
        let readTypes : Set = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!
        ]
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        
        healthKitStore.requestAuthorizationToShareTypes(shareTypes, readTypes:readTypes, completion: { (success, error) -> Void in
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        })
    }

    
    //读取重量
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
    {
        
        // 1. Build the Predicate
        let past = NSDate.distantPast() as! NSDate
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    completion(nil,error)
                    return;
                }
                
                // Get the first sample
                let mostRecentSample = results!.first as? HKQuantitySample
                
                // Execute the completion closure
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        // 5. Execute the Query
        self.healthKitStore.executeQuery(sampleQuery)
    }


}
