//
//  SleepEntryDetailViewController.swift
//  Sleep Pal
//
//  Created by Cody Caldwell on 7/26/15.
//  Copyright (c) 2015 Cody Caldwell. All rights reserved.
//

import UIKit
import HealthKit

class SleepEntryDetailViewController: UIViewController {
    
    @IBOutlet weak var deepLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var awakeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var sleepQualityLabel: UILabel!
    
    let redColor = UIColor(red: 255.0/255.0, green: 76.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    let blueColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    let greenColor = UIColor(red: 75.0/255.0, green: 198.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    let formatter = NSDateFormatter()
    
    var sleepSample: HKCategorySample!
    var chart: JBBarChartView!
    var sleepData: [SleepType]!

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        sleepData = SleepAnalyzer.getSleepTypesFromSample(sleepSample)
        setupUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func setupUI() {
        setupTitle()
        setupChart()
        setupLabels()
    }
    
    func setupChart() {
        chart = JBBarChartView()
        chart.dataSource = self
        chart.delegate = self
        chart.inverted = false
        chart.minimumValue = 0
        chart.maximumValue = 12
        chart.headerPadding = 20
        chart.state = JBChartViewState.Expanded
        chart.frame = CGRectMake(10, 10, self.view.bounds.size.width - (10 * 2), 250)
        self.view.addSubview(chart)
        chart.reloadData()
    }
    
    func setupLabels() {
        
        // Time label
        formatter.dateFormat = "h:mm a"
        timeLabel.text = "\(formatter.stringFromDate(sleepSample.startDate)) - \(formatter.stringFromDate(sleepSample.endDate))"
        
        // Duration label
        var intervalInSeconds = sleepSample.endDate.timeIntervalSinceDate(sleepSample.startDate)
        let hours = floor(intervalInSeconds / 3600)
        if (hours > 0) { intervalInSeconds -= hours * 3600 }
        let minutes = floor(intervalInSeconds / 60)
        if (minutes > 0) { intervalInSeconds -= minutes * 60 }
        durationLabel.text = "\(Int(round(hours)))h \(Int(round(minutes)))min"
        
        // Deep / Light / Awake labels
        let amounts = SleepAnalyzer.countSleepTypePercentages(sleepData)
        deepLabel.text = "\(amounts.deepPercentage)%"
        lightLabel.text = "\(amounts.lightPercentage)%"
        awakeLabel.text = "\(amounts.awakePercentage)%"
        
        sleepQualityLabel.text = "\(100 - amounts.awakePercentage)%"
        
    }
    
    func setupTitle() {
        formatter.dateFormat = "MMM dd, yyyy"
        self.navigationItem.title = formatter.stringFromDate(sleepSample.startDate)
    }

}

extension SleepEntryDetailViewController : JBBarChartViewDelegate, JBBarChartViewDataSource {
    
    // MARK: JBBarChartViewDataSource
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(sleepData?.count ?? 0)
    }
    
    // Mark: JBBarChartViewDelegate
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        let idx = Int(index)
        let type = sleepData![idx]
        return type == .Deep ? 3 : type == .Light ? 6 : 9
    }
    
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        let idx = Int(index)
        let type = sleepData![idx]
        return type == .Deep ? blueColor : type == .Light ? greenColor : redColor
    }
    
    func barPaddingForBarChartView(barChartView: JBBarChartView!) -> CGFloat {
        return 0.0
    }
    
}
