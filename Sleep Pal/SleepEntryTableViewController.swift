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
    
    
    // MARK: Life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSleepData", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshSleepData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SleepEntryCell", forIndexPath: indexPath) as! SleepEntryCell
        
        let sleepData = entries[indexPath.row]
        let startDate = sleepData.startDate
        let endDate = sleepData.endDate
        
        cell.dateLabel.text = getDateStringForSleepData(sleepData)
        cell.timeLabel.text = getTimeStringForSleepData(sleepData)
        cell.durationLabel.text = getDurationStringForSleepData(sleepData)
        cell.sleepEfficiencyLabel.text = getSleepEfficiencyStringForSleepData(sleepData)

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("entryDetail", sender: self.entries[indexPath.row])
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "entryDetail") {
            let dvc = segue.destinationViewController as! SleepEntryDetailViewController
            let sleepData = sender as! HKCategorySample
            dvc.sleepSample = sleepData
        }
    }
    
    // MARK: Helper methods
    
    func refreshSleepData() {
        healthManager.readSleepData({ [weak self](results, error) -> Void in
            if let results = results {
                self!.entries = (results as! [HKCategorySample]).filter({ (data: HKCategorySample) -> Bool in
                    return data.source == HKSource.defaultSource()
                })
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self!.tableView.reloadData()
                })
            }
        })
    }
    
    func getDateStringForSleepData(sleepData: HKCategorySample) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.stringFromDate(sleepData.startDate)
    }
    
    func getTimeStringForSleepData(sleepData: HKCategorySample) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return "\(formatter.stringFromDate(sleepData.startDate)) - \(formatter.stringFromDate(sleepData.endDate))"
    }
    
    func getDurationStringForSleepData(sleepData: HKCategorySample) -> String {
        var intervalInSeconds = sleepData.endDate.timeIntervalSinceDate(sleepData.startDate)
        let hours = floor(intervalInSeconds / 3600)
        if (hours > 0) { intervalInSeconds -= hours * 3600 }
        let minutes = floor(intervalInSeconds / 60)
        if (minutes > 0) { intervalInSeconds -= minutes * 60 }
        return "\(Int(hours))h \(Int(minutes))min"
    }
    
    func getSleepEfficiencyStringForSleepData(sleepSample: HKCategorySample) -> String {
        
        // DELETE LATER: Repitition
        let sleepData = SleepAnalyzer.getSleepTypesFromSample(sleepSample)
        let sleepQualityPercentage = SleepAnalyzer.determineSleepQuality(sleepData)
        return "\(sleepQualityPercentage)%"
    }
}
