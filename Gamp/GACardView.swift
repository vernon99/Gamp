//
//  GACardView.swift
//  Gamp
//
//  Created by Mikhail Larionov on 7/19/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

import UIKit

class GACardView: UIView {
    
    var loadingStarted = false
    
    var buildString: String? = nil {
    didSet{
            if let build = buildString
            {
                labelBuild.text = labelBuild.text + build
            }
        }
    }
    var startDate: NSDate = NSDate()
    var endDate: NSDate = NSDate()
    {
        didSet{
        }
    }
    
    @IBOutlet weak var labelLifetime: UILabel!
    @IBOutlet weak var labelARPDAU: UILabel!
    @IBOutlet weak var labelLTV: UILabel!
    @IBOutlet weak var lineChart: PNLineChart!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelBuild: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    
    class func instanceFromNib() -> GACardView {
        var result:UINib = UINib(nibName: "GACardView", bundle: NSBundle.mainBundle())
        var array = result.instantiateWithOwner(nil, options: nil)
        return array[0] as GACardView
    }
    
    func prepare()
    {
        // Setup chart
        lineChart.setDefaultValues()
        lineChart.yLabelFormat = "%1.2f"
        lineChart.showLabel = true
        lineChart.yValueStartsFromZero = true
        lineChart.showCoordinateAxis = false
        lineChart.yLabelMaxCount = 10
        lineChart.clipsToBounds = false
    }
    
    func load() {
        
        loadingStarted = true
        
        // Start animating
        activityIndicator.startAnimating()
        
        // Fetch data
        var collection = GACohortDataCollection(build:buildString, start:startDate, end:endDate)
        collection.startLoading({
            
            // Stop animating
            dispatch_async(dispatch_get_main_queue(), {
                
                self.activityIndicator.stopAnimating()
            })
            
            // Check if the params were set up
            if gameId == "NUMBER_HERE"
            {
                self.labelStatus.hidden = false;
                self.labelStatus.text = "You haven't set game id and secret, check Config.swift file"
                return
            }
            
            // Check data
            var retentionArray = collection.averageRetentionByDay
            if retentionArray.count < 2
            {
                self.labelStatus.hidden = false
                self.labelStatus.text = "Insufficient data, need at least two days from build launch"
                return
            }
            
            // Add estimated data to historical if needed
            var estimation:Array<Float> = []
            if let retentionDecay = collection.retentionDecay
            {
                estimation = retentionDecay.dataForDaysTill(maximumRetentionDays)
                for var n = retentionArray.count; n < estimation.count; n++
                {
                    retentionArray.append(estimation[n])
                }
            }
            
            // Create charts
            var arrayDays:[String] = [];
            var counter:Int = 0
            for point in retentionArray
            {
                if counter % 5 == 0 {
                    arrayDays.append(String(counter))
                }
                else {
                    arrayDays.append("")
                }
                counter++
            }
            
            // Historical chart
            var historicalData = PNLineChartData()
            historicalData.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleNone
            historicalData.color = PNGreenColor
            historicalData.itemCount = retentionArray.count
            historicalData.getData = ({(index: Int) -> PNLineChartDataItem in
                
                var item = PNLineChartDataItem()
                item.y = CGFloat(retentionArray[index] as NSNumber)
                return item
                })
            
            // Estimated chart
            var estimatedData = PNLineChartData()
            estimatedData.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleNone
            estimatedData.color = PNGreyColor
            estimatedData.itemCount = estimation.count
            estimatedData.getData = ({(index: Int) -> PNLineChartDataItem in
                
                var item = PNLineChartDataItem()
                item.y = CGFloat(estimation[index] as Float)
                return item
                })
            
            // Redraw in the main thread
            dispatch_async(dispatch_get_main_queue(), {
                
                // Key numbers
                self.labelLifetime.text = NSString(format:"%.2f d", collection.userLifetime)
                self.labelARPDAU.text = NSString(format:"$%.3f", collection.averageARPDAU)
                self.labelLTV.text = NSString(format:"$%.3f", collection.lifetimeValue)
                
                // Chart
                self.lineChart.xLabels = arrayDays
                self.lineChart.chartData = [estimatedData, historicalData]
                self.lineChart.strokeChart()
            })
        })
    }
}
