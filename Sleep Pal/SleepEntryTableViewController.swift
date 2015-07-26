//
//  SleepEntryTableViewController.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/26/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit
import HealthKit

class SleepEntryTableViewController: UITableViewController {
    
    var entries = [HKCategorySample]()
    let healthManager = HealthKitManager.sharedManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        healthManager.readSleepData({ [weak self](results, error) -> Void in
            if let results = results {
                self!.entries = results as! [HKCategorySample]
            }
        })
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return entries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SleepEntryCell", forIndexPath: indexPath) as! UITableViewCell


        return cell
    }
}
