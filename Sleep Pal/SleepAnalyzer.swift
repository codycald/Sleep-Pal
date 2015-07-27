//
//  SleepAnalyzer.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/26/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit
import CoreMotion

class SleepAnalyzer: NSObject {
   
    var prevX: Double = 0.0
    var prevY: Double = 0.0
    var first: Bool = true
    var step: Int = 0
    var maxDiffX: Double = 0.0
    var maxDiffY: Double = 0.0
    var interval: NSTimeInterval!
    var maxStep: Int = 0
    var analyzedData = [SleepType]()
    
    convenience init(updateInterval: NSTimeInterval, secondsPerMeasurement: Int) {
        self.init()
        self.interval = updateInterval
        self.maxStep = determineMaxStep(updateInterval, secondsPerMeasurement: secondsPerMeasurement)
        println("maxStep = \(maxStep)")
    }
    
    func updateWithAccelerometerData(data: CMAccelerometerData!) {
        step++
        if (maxStepCountReached()) {
            determineSleepType()
            reset()
            return
        }
        update(data)
    }
    
    func getAnalyzedSleepData() -> [SleepType] {
        return analyzedData
    }
    
    func clearAllData() {
        reset()
        analyzedData = [SleepType]()
    }
    
    private func reset() {
        prevX = 0.0
        prevY = 0.0
        first = true
        step = 0
        maxDiffX = 0.0
        maxDiffY = 0.0
    }
    
    private func update(data: CMAccelerometerData!) {
        if let data = data {
            if (first) { prevX = data.acceleration.x; prevY = data.acceleration.y; first = false; return; }
            maxDiffX = max(maxDiffX, abs(data.acceleration.x - prevX))
            maxDiffY = max(maxDiffY, abs(data.acceleration.y - prevY))
        }
    }
    
    private func maxStepCountReached() -> Bool {
        return step == maxStep
    }
    
    private func determineMaxStep(updateInterval: NSTimeInterval, secondsPerMeasurement: Int) -> Int {
        return Int(round((Double(secondsPerMeasurement) / updateInterval)))
    }
    
    private func determineSleepType() {
        maxDiffX *= 1000
        maxDiffY *= 1000
        analyzedData.append(maxDiffX + maxDiffY <= 10 ? .Deep : maxDiffX + maxDiffY <= 30 ? .Light : .Awake)
    }
}
