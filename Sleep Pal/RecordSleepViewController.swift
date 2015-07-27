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
    
    let healthManager = HealthKitManager.sharedManager()
    
    var recording = false
    var startDate: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        healthManager.authorize {
            success, error in
            if (!success) {
                // Error
            }
        }
    }

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
        } else {
            // Stop recording
            let stopDate = NSDate()
            var intervalInSeconds = stopDate.timeIntervalSinceDate(startDate)
            let hours = floor(intervalInSeconds / 3600)
            if (hours > 0) { intervalInSeconds -= hours * 3600 }
            let minutes = floor(intervalInSeconds / 60 )
            if (minutes > 0) { intervalInSeconds -= minutes * 60 }
            let seconds = intervalInSeconds
            println("Stopping. Recording was: \(hours) hours, \(minutes) minutes, and \(seconds) seconds")
            var metaData: [NSObject : AnyObject] = [:]
            healthManager.saveSleepData(startDate: startDate, stopDate: stopDate, metadata: metaData, completion: {
                success, error in
                if (success) { self.showSaveSuccessfulNotification() }
            })
        }
    }
    
    func showSaveSuccessfulNotification() {
        let alert = UIAlertController(title: "Good Morning!", message: "Your sleep data has been synced to HealthKit!", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) {
            [weak self] action in
            self!.tabBarController?.selectedIndex = 1
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

