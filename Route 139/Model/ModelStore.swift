//
//  ModelStore.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/8/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

class ModelStore {
    
    private static let instance = ModelStore()
   
    class var sharedInstance: ModelStore {
        return instance
    }
    
    var toTerminalStop1   : RouteStop? = nil
    var toTerminalStop2   : RouteStop? = nil
    var toTerminalStop3   : RouteStop? = nil
    
    var fromTerminalStop1 : RouteStop? = nil
    var fromTerminalStop2 : RouteStop? = nil
    var fromTerminalStop3 : RouteStop? = nil
    
    // MARK: - Need Work
    
    private func getFullSchedule() -> Array<ScheduleEntry> {
        // Has to be done in a different way
        let allStops = RouteStop.FromRouteFetcher( RouteFetcher.loadStops() )
        var stopDictionary = Dictionary<Int,RouteStop>()
        for stop in allStops  {
            stopDictionary[stop.Identity] = stop
        }
        
        return ScheduleEntry.FromRouteFetcher(RouteFetcher.loadSchedule(), stops: stopDictionary)
    }
    
    // Has to be done in a different way
    func locationsToTerminal() -> Locations {
        let allSchedule = getFullSchedule()
        var locations = Locations()
        
        for schedule in allSchedule {
            if schedule.toTerminal {
                locations.addStop(schedule.stop)
            }
        }

        return locations
    }
    
    // Has to be done in a different way
    func locationsFromTerminal() -> Locations {
        let allSchedule = getFullSchedule()
        var locations = Locations()
        
        for schedule in allSchedule {
            if !schedule.toTerminal {
                locations.addStop(schedule.stop)
            }
        }
        
        return locations
    }
    
    func nextScheduleEntry( toTerminal : Bool, stop: RouteStop ) -> Array<ScheduleEntry> {
        
        var ret = Array<ScheduleEntry>()
        
        let date = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components(
            .CalendarUnitHour
                | .CalendarUnitMinute
                | NSCalendarUnit.CalendarUnitWeekday,
            fromDate: date)
        let now = components.hour * 100 + components.minute
        let weekDay = components.weekday // 2 = Monday
        
        
        for scheduleEntry in getFullSchedule() {
            if scheduleEntry.toTerminal == toTerminal && scheduleEntry.stop.Equals(stop) {
                if checkSchedule(scheduleEntry, now: now, weekDay: weekDay) {
                    ret.append(scheduleEntry)
                }
            }
        }
        
        if ret.count < 5 {
            // try to get from next day
            let nextWeekDay = weekDay + 1 > 7 ? 1 : weekDay + 1
            
            for scheduleEntry in getFullSchedule() {
                if scheduleEntry.toTerminal == toTerminal && scheduleEntry.stop.Equals(stop) {
                    if checkSchedule(scheduleEntry, now: 0, weekDay: nextWeekDay) {
                        ret.append(scheduleEntry)
                    }
                }
            }
            
        }
        
        return ret
    }
    
    private func checkSchedule( scheduleEntry : ScheduleEntry, now : Int, weekDay : Int ) -> Bool {
        
        if weekDay >= 2 && weekDay <= 6 {
            // Monday - Friday
            switch scheduleEntry.dayType {
            case .Weekday:
                return scheduleEntry.scheduleTime > now
            case .Tue2Fri:
                if weekDay == 2 {
                    return false
                } else {
                return scheduleEntry.scheduleTime > now
                }
            case .Sat:
                return false
            case .Sun:
                return false
            case .Mon:
                if weekDay == 2 {
                    return scheduleEntry.scheduleTime > now
                } else {
                    return false
                }
            case .Weekend:
                return false
            case .Holiday:
                return false
            case .Mon2Thu:
                if weekDay == 6 {
                    return false
                } else {
                    return scheduleEntry.scheduleTime > now
                }
            }
        } else {
            // Weekend
            switch scheduleEntry.dayType {
            case .Weekday:
                return false
            case .Tue2Fri:
                return false
            case .Sat:
                return scheduleEntry.scheduleTime > now
            case .Sun:
                return scheduleEntry.scheduleTime > now
            case .Mon:
                return false
            case .Weekend:
                return scheduleEntry.scheduleTime > now
            case .Holiday:
                return false
            case .Mon2Thu:
                return false
            }
        }
    }
    
    func save() {
        
    }


}