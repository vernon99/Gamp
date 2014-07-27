//
//  CohortDataCollection.swift
//  Gamp
//
//  Created by Mikhail Larionov on 7/18/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

import Foundation

enum GALoadingStage
{
    case LoadingRetention(Int)
    case LoadingARPDAU
    case LoadingComplete
}

let maximumRetentionDays = 30

class GACohortDataCollection
{
    var averageRetentionByDay:[Float] = []
    var retentionDecay:GARetentionDecay? = nil
    
    var averageARPDAU:Float = 0.0
    var userLifetime:Float = 1.0        // To include zero day as we're calculating retention from 1st day
    var lifetimeValue:Float = 0.0
    
    var buildString:String? = nil
    var startDate:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    var loadingStage:GALoadingStage = .LoadingRetention(1)
    var completionBlock:(() -> Void)?
    
    func startLoading(completion:(() -> Void))
    {
        completionBlock = completion
        loadNextStage()
    }
    
    func loadNextStage()
    {
        // Start loading
        switch loadingStage {
        case .LoadingRetention(let day):
            if ( day <= maximumRetentionDays )
            {
                loadRetentionDataByDay(day)
                loadingStage = .LoadingRetention(day+1)
            }
            else
            {
                loadARPDAU()
                loadingStage = .LoadingARPDAU
            }
            break
        case .LoadingARPDAU:
            loadingStage = .LoadingComplete
            prepareKeyNumbers()
            if ( completionBlock )
            {
                completionBlock!()
            }
            break
        default:
            break
        }
    }
    
    func prepareKeyNumbers()
    {
        // Calculate retention estimation
        retentionDecay = GARetentionDecay(historicalData:averageRetentionByDay)
        
        // Use historical data first
        for percentage in averageRetentionByDay
        {
            userLifetime += percentage
        }
        
        // Apply estimated data till the end of 180 day period
        for var day = averageRetentionByDay.count; day < 180; day++
        {
            userLifetime += retentionDecay!.dataForSpecificDay(day)
        }
        
        // Finally, we haven't counted zero day. It's a big question on how should we use this data as 100% of users were active at day 0, but some of them just launched the game and closed it. It is safe to assume that users who came back at day 1 have same activity rate as zero day users. So we add 1st day retention for zero day here.
        userLifetime += averageRetentionByDay[0]
        
        // Calculate LTV now
        lifetimeValue = userLifetime * averageARPDAU
    }
    
    func loadRetentionDataByDay(day:Int)
    {
        var dataWrapper = GADataWrapper()
        var queryString = "retention_";
        queryString += String(day)
        queryString += "?start="
        queryString += String(Int(startDate.timeIntervalSince1970))
        queryString += "&end="
        queryString += String(Int(endDate.timeIntervalSince1970))
        if ( buildString )
        {
            queryString += "&build=" + buildString!
        }
        NSLog("Query: \(queryString)")
        dataWrapper.loadData(queryString, closure: {
            (json:NSDictionary?) -> Void in
            
            var succeeded = false
            
            if ( json )
            {
                let jsonSafe = JSONValue(json!)
                
                if let results = jsonSafe["timeseries"]["retention_"+String(day)].array {
                    
                    var average:Float = 0.0
                    var count:Int = 0
                    for item in results
                    {
                        if let build = self.buildString
                        {
                            if let number = item["dimensions"]["build"][build].number
                            {
                                average += number.floatValue
                                count++
                            }
                        }
                        else
                        {
                            if let number = item["total"].number
                            {
                                average += number.floatValue
                                count++
                            }
                        }
                    }
                    if ( count > 0 )
                    {
                        average /= Float(count)
                        self.averageRetentionByDay.append(average)
                        NSLog("Count: \(results.count), average for Day \(day): \(average)")
                        succeeded = true
                    }
                }
            }
            
            // Skip retention load if any errors
            if !succeeded
            {
                self.loadingStage = .LoadingRetention(maximumRetentionDays+1)
            }
            
            // Start next cycle
            self.loadNextStage()
        })
    }
    
    func loadARPDAU()
    {
        var dataWrapper = GADataWrapper()
        var queryString = "ARPDAU?start=";
        queryString += String(Int(startDate.timeIntervalSince1970))
        queryString += "&end="
        queryString += String(Int(endDate.timeIntervalSince1970))
        if ( buildString )
        {
            queryString += "&build=" + buildString!
        }
        queryString += "&currency=USD"
        NSLog("Query: \(queryString)")
        dataWrapper.loadData(queryString, closure: {
            (json:NSDictionary?) -> Void in
            
            if ( json )
            {
                let jsonSafe = JSONValue(json!)
                
                if let results = jsonSafe["timeseries"]["ARPDAU"].array {
                    
                    var average:Float = 0.0
                    var count:Int = 0
                    for item in results
                    {
                        if let build = self.buildString
                        {
                            if let number = item["dimensions"]["build"][build].number
                            {
                                average += number.floatValue
                                count++
                            }
                        }
                        else
                        {
                            if let number = item["total"].number
                            {
                                average += number.floatValue
                                count++
                            }
                        }
                    }
                    if ( count > 0 )
                    {
                        average /= Float(count)
                    }
                    else
                    {
                        average = 0.0
                    }
                    
                    self.averageARPDAU = average
                    
                    NSLog("ARPDAU count: \(results.count), average: \(average)")
                }
            }
            
            // Start next cycle
            self.loadNextStage()
        })
    }
    
    init(build:String?, start:NSDate, end:NSDate) {
        buildString = build
        startDate = start
        endDate = end
    }
}