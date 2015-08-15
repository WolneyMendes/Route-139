//
//  ScheduleEntry.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/15/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class ScheduleEntry {
    public let stopTime : RouteStopTime
    public let terminalTime : RouteStopTime
    
    private var _isNextDay = false
    
    public var NextDay : Bool {
        get { return _isNextDay }
    }
    
    init( stopTime: RouteStopTime, terminalTime: RouteStopTime) {
        self.stopTime = stopTime
        self.terminalTime = terminalTime
    }
    
    init( stopTime: RouteStopTime, terminalTime: RouteStopTime, nextDay: Bool ) {
        self.stopTime = stopTime
        self.terminalTime = terminalTime
        self._isNextDay = nextDay
    }
    
    
}
