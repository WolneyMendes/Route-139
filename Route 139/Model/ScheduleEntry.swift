//
//  ScheduleEntry.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/29/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class ScheduleEntry {
    
    public let stop : RouteStop
    public let line : Int
    public let dayType : DayType
    public let tripNumber : Int
    public let toTerminal : Bool
    
    public let scheduleTime : Int
    
    init(stop:RouteStop, line:Int, dayType:DayType, tripNumber:Int, toTerminal:Bool, scheduleTime:Int) {
        self.stop = stop
        self.line = line
        self.dayType = dayType
        self.tripNumber = tripNumber
        self.toTerminal = toTerminal
        self.scheduleTime = scheduleTime
    }
    
    public static func FromRouteFetcher( schedule: Array<Dictionary<String, AnyObject>>, stops : Dictionary<Int,RouteStop> ) -> Array<ScheduleEntry> {
        
        var ret = schedule.map( { (
            var schedule) -> ScheduleEntry in
            
            let stopIdentity = schedule[ RouteFetcherConstants.ScheduleStopIdentity ] as! Int
            let stop = stops[stopIdentity]!
            let line = schedule[ RouteFetcherConstants.ScheduleLine ] as! Int
            let dayType = DayType(rawValue: schedule[ RouteFetcherConstants.ScheduleDateType ] as! Int)!
            let tripNumber = schedule[ RouteFetcherConstants.ScheduleTripNumber ] as! Int
            let toTerminal = schedule[ RouteFetcherConstants.ScheduleTripDirection ] as! Int == 0
            let scheduleTime = (schedule[ RouteFetcherConstants.ScheduleHHMM ] as! String).toInt()!
            
            return ScheduleEntry(
                stop: stop,
                line: line,
                dayType:
                dayType,
                tripNumber:
                tripNumber,
                toTerminal: toTerminal,
                scheduleTime: scheduleTime )
            
        } )
        
        return ret;
    }
    
}