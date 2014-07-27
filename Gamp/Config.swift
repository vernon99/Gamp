//
//  Config.swift
//  Gamp
//
//  Created by Mikhail Larionov on 7/27/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

import Foundation

// Game settings
let gameId = "NUMBER_HERE"  // Could be found in the GA link to game settings
let gameAPISecret = "API_SECRET_HERE" // Could be found in game settings, last number

// Build settings, in future will be grabbed and cached upon first launch,
// now you need to setup manually in descending order
let builds:Array<(build:String, date:String)> = [("1.08", "07.16.2014"), ("1.07", "06.27.2014"), ("1.05", "06.20.2014"), ("1.04", "06.06.2014"), ("1.03", "05.29.2014"), ("1.02", "05.18.2014"), ("1.01", "05.09.2014"), ("1.00", "05.01.2014") ]