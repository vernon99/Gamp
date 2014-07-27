//
//  RetentionDecay.swift
//  Gamp
//
//  Created by Mikhail Larionov on 7/18/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

import Foundation

class GARetentionDecay {
    
    var a:Float = 0
    var b:Float = 0
    
    // Ordinary least squares regression model
    // See more at http://en.wikipedia.org/wiki/Ordinary_least_squares
    init (historicalData:NSArray)
    {
        var sumX:Float = 0
        var sumX2:Float = 0
        var sumY:Float = 0
        var sumXY:Float = 0
        var avX:Float = 0
        var avY:Float = 0
        let n:Float = Float(historicalData.count)
        for var step = 0; step < historicalData.count; step++
        {
            let x:Float = Float(step)
            let historical = historicalData[step] as Float
            var y:Float = 0
            if historical != 0.0 {
                y = logf(historical)
            }
            sumX += x
            avX += x
            sumX2 += x*x
            sumY += y
            avY += y
            sumXY += x*y
        }
        
        avX /= Float(historicalData.count)
        avY /= Float(historicalData.count)
        
        let c1:Float = (sumXY - 1.0/n * sumX * sumY) / (sumX2 - 1.0/n * sumX * sumX)
        let c0:Float = avY - c1*avX
        
        a = expf(c0)    // c0 = lnA
        b = -1.0/c1     // c1 = -1/b
    }
    
    func dataForSpecificDay(day:Int) -> Float
    {
        let x = Float(day)
        var y = a * exp(-Float(x)/b)
        return y
    }
    
    func dataForDaysTill(steps:Int) -> Array<Float>
    {
        var result:Array<Float> = []
        for var step = 0; step < steps; step++
        {
            var y = dataForSpecificDay(step)
            result.append(y)
        }
        return result
    }
}