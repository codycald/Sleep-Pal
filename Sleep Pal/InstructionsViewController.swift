//
//  InstructionsViewController.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/27/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    @IBOutlet weak var shouldShowAgainSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func donePressed(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(shouldShowAgainSwitch.on, forKey: "skipInstructions")
        dismissViewControllerAnimated(true, completion: nil)
    }
}
