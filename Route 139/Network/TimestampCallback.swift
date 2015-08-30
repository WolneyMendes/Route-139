//
//  TimestampCallback.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/28/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class TimestampCallBack : RestCallBack {
    
    public func jsonCallBack(url: NSURL, timestamp: Int, json:AnyObject?) {
        if let timeStampDictionary = json as? NSDictionary {
            var stopsTS = timeStampDictionary[ "stops" ] as! Int
            var stopTimeTS = timeStampDictionary[ "stopTimes" ] as! Int
            var routesTS = timeStampDictionary[ "routes" ] as! Int
            var tripsTS = timeStampDictionary[ "trips" ] as! Int
            var calendarTS = timeStampDictionary[ "calendar_dates"] as! Int
        }
    }
    
    public func textCallBack(url: NSURL, text: String) {
        
    }
    
    public func errorCallBack(url: NSURL, error: NSError) {
        
    }
    
    public func externalErrorCallBack(url: NSURL, error: NSError) {
        
    }
}
