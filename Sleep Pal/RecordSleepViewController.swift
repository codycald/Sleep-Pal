//
//  RecordSleepViewController.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/24/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit

class RecordSleepViewController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    let greenColor = UIColor(red: 75.0/255.0, green: 198.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    let redColor = UIColor.redColor()
    
    var recording = false
    var startDate: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            println("Stopped recording. End date is: \(stopDate)")
        }
    }
}

