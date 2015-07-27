//
//  HealthKitManager.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/26/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit
import HealthKit

class HealthKitManager: NSObject {
   
    let healthKitStore = HKHealthStore()
    let categoryType: HKObjectType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
    static var instance: HealthKitManager?
    
    class func sharedManager() -> HealthKitManager {
        if (instance == nil) {
            instance = HealthKitManager()
        }
        return instance!
    }
    
    func authorize(completion: ((success: Bool, error: NSError!) -> Void)!) {
        if (HKHealthStore.isHealthDataAvailable()) {
            healthKitStore.requestAuthorizationToShareTypes([categoryType], readTypes: [categoryType]) {
                success, error in
                if let callback = completion {
                    callback(success: success, error: error)
                }
            }
        }
    }
    
    func hasAuthorization() -> Bool {
        if (HKHealthStore.isHealthDataAvailable()) {
            let status = healthKitStore.authorizationStatusForType(categoryType)
            if (status == HKAuthorizationStatus.SharingAuthorized) {
                return true
            }
        }
        return false
    }
    
    func saveSleepData(#startDate: NSDate, stopDate: NSDate, metadata: [NSObject : AnyObject]!, completion: ((Bool, NSError!)-> Void)!) {
        if (!hasAuthorization()) { return }
        let sampleType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        println(sampleType)
        let sampleValue = HKCategoryValueSleepAnalysis.Asleep.rawValue
        let sample = HKCategorySample(type: sampleType, value: sampleValue, startDate: startDate, endDate: stopDate, metadata: metadata)
        
        healthKitStore.saveObject(sample, withCompletion: { (success, error) -> Void in
            if let callback = completion {
                callback(success, error)
            }
        })
    }
    
    func readSleepData(completion: (([AnyObject]!, NSError!) -> Void)!) {
        let asleep = HKQuery.predicateForCategorySamplesWithOperatorType(.EqualToPredicateOperatorType, value: HKCategoryValueSleepAnalysis.Asleep.rawValue)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleType = HKSampleType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        let query = HKSampleQuery(sampleType: sampleType, predicate: asleep, limit: 0, sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
            if let callback = completion {
                callback(results, error)
            }
        }
        healthKitStore.executeQuery(query)
    }
    
    
}
