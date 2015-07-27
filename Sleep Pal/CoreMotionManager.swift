//
//  CoreMotionManager.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/26/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit
import CoreMotion

class CoreMotionManager: NSObject {
    
    let manager = CMMotionManager()
    static var instance: CoreMotionManager?
    
    class func sharedManager() -> CoreMotionManager {
        if (instance == nil) {
            instance = CoreMotionManager()
        }
        return instance!
    }
    
    func startReceivingAccelerometerUpdatesWithInterval(interval: NSTimeInterval, completion: ((CMAccelerometerData!, NSError!) -> Void)!) {
        if (manager.accelerometerAvailable) {
            manager.stopAccelerometerUpdates()
            manager.accelerometerUpdateInterval = interval
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {
                data, error in
                if let callback = completion { callback(data, error) }
            })
        }
    }
    
    func stopReceivingAccelerometerUpdates(completion: (() -> Void)!) {
        if (manager.accelerometerAvailable) {
            manager.stopAccelerometerUpdates()
            if let callback = completion { callback() }
        }
    }
}
