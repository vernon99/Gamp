//
//  DataWrapper.swift
//  Gamp
//
//  Created by Mikhail Larionov on 7/15/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

import Foundation

class GADataWrapper {
    
    var requestData: NSMutableData? = nil
    var isLoading: Bool = false
    
    func loadData(query: String, closure: ((json: NSDictionary?) -> Void) ) {
        isLoading = true
        let endpoint = "https://query.gameanalytics.com"
        let path = "/v1/games/\(gameId)/core/" + query
        
        // Calculate token
        var dictionary = NSDictionary(object: path, forKey: "url")
        var encodedToken = JWT.encodePayload(dictionary, withSecret:gameAPISecret)
        
        // Create request
        let url = NSURL(string: endpoint + path)
        var request = NSMutableURLRequest(URL: url)
        request.addValue(encodedToken, forHTTPHeaderField: "Authorization")
        
        // Start session
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler:{
            data, response, error -> Void in
            
            if let data:NSData = data {
                
                var dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                NSLog("Data: \(dataString).")
                
                var err: NSError?
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                if let error = err {
                    NSLog("Error: \(error.localizedDescription)")
                }
                else {
                    closure(json: jsonResult)
                    return
                }
            }
            
            closure(json: nil)
        })
        task.resume()
    }
}