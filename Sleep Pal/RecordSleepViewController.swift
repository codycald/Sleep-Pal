//
//  RecordSleepViewController.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/24/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit
import HealthKit

class RecordSleepViewController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    let greenColor = UIColor(red: 75.0 / 255.0, green: 198.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
    let redColor = UIColor.redColor()
    
    let accelerometerUpdateInterval = 0.5
    let secondsPerSleepMeasurement = 6
    
    let healthManager = HealthKitManager.sharedManager()
    let motionManager = CoreMotionManager.sharedManager()
    var sleepAnalyzer: SleepAnalyzer!
    
    var recording = false
    var startDate: NSDate!
    
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        healthManager.authorize {
            success, error in
            if (!success) {
                // Error
            }
        }
        sleepAnalyzer = SleepAnalyzer(updateInterval: accelerometerUpdateInterval, secondsPerMeasurement: secondsPerSleepMeasurement)
    }
    
    // MARK: IBActions

    @IBAction func startPressed(sender: AnyObject) {
        if (!recording) {
            startButton.setTitle("Stop", forState: .Normal)
            startButton.backgroundColor = redColor
        } else {
            startButton.setTitle("Start", forState: .Normal)
            startButton.backgroundColor = greenColor
        }
        
        recording = !recording
        
        if (recording) {
            // Start recording
            startDate = NSDate()
            println("Began recording. Start date is: \(startDate)")
            motionManager.startReceivingAccelerometerUpdatesWithInterval(0.5, completion: {
                [weak self] data, error in
                self!.sleepAnalyzer.updateWithAccelerometerData(data)
            })
        } else {
            // Stop recording
            motionManager.stopReceivingAccelerometerUpdates({ println("Accelerometer stoppped") })
            let sleepData = sleepAnalyzer.getAnalyzedSleepData()
            sleepAnalyzer.clearAllData()
            
            let stopDate = NSDate()
            var metaData: [NSObject : AnyObject] = getMetadataFromSleepData(sleepData)
            healthManager.saveSleepData(startDate: startDate, stopDate: stopDate, metadata: metaData, completion: {
                success, error in
                if (success) { self.showSaveSuccessfulNotification() }
            })
        }
    }
    
    // MARK: Helper methods
    
    func showSaveSuccessfulNotification() {
        let alert = UIAlertController(title: "Good Morning!", message: "Your sleep data has been synced to HealthKit!", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) {
            [weak self] action in
            self!.tabBarController?.selectedIndex = 1
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getMetadataFromSleepData(sleepData: [SleepType]) -> [NSObject : AnyObject] {
        var res = [NSObject : AnyObject]()
        var pattern = ""
        for data in sleepData {
            pattern += data == .Deep ? "0" : data == .Light ? "1" : "2"
        }
        res["Sleep Pattern"] = pattern
        return res
    }
}

