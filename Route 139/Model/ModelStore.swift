//
//  ModelStore.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/8/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class ModelStore {
    
    private var configurationManager : ConfigurationManager? {
        didSet {
            loadFromConfig()
        }
    }
   
    public var toTerminalStop1   : RouteStop? = nil {
        didSet {
            if oldValue !== toTerminalStop1 {
                configurationManager?.toTerminalStop1 = toTerminalStop1?.Identity
            }
        }
    }
    
    public var toTerminalStop2   : RouteStop? = nil {
        didSet {
            if oldValue !== toTerminalStop2 {
                configurationManager?.toTerminalStop2 = toTerminalStop2?.Identity
            }
        }
    }
    
    public var toTerminalStop3   : RouteStop? = nil {
        didSet {
            if oldValue !== toTerminalStop3 {
                configurationManager?.toTerminalStop3 = toTerminalStop3?.Identity
            }
        }
    }
    

    
    public var fromTerminalStop1 : RouteStop? = nil {
        didSet {
            if oldValue !== fromTerminalStop1 {
                configurationManager?.fromTerminalStop1 = fromTerminalStop1?.Identity
            }
        }
    }
    
    public var fromTerminalStop2 : RouteStop? = nil {
        didSet {
            if oldValue !== fromTerminalStop2 {
                configurationManager?.fromTerminalStop2 = fromTerminalStop2?.Identity
            }
        }
    }
    
    public var fromTerminalStop3 : RouteStop? = nil {
        didSet {
            if oldValue !== fromTerminalStop3 {
                configurationManager?.fromTerminalStop3 = fromTerminalStop3?.Identity
            }
        }
    }
    
    public var inboundTerminalStop : RouteStop?  {
        return self.modelBuilder?.inBoundTerminal
    }
    
    public var outboundTerminalStop : RouteStop? {
        return self.modelBuilder?.outBoundTerminal
    }
    
    private var modelBuilder : ModelBuilder?
    
    // MARK: - Initializer
    
    init( configManager: ConfigurationManager ) {
        
        self.configurationManager = configManager
        self.loadFromConfig()
    }
    
    func getRoute ( fromTrip: Int ) -> Route? {
        return modelBuilder!.routesDictionary![modelBuilder!.tripsDictionary![fromTrip]!.RouteId]
    }
    
    // MARK: - Need Work
    
    func getLocationsToTerminal() -> Locations {
        return modelBuilder!.inboundLocations!;
    }
    
    func getLocationsFromTerminal() -> Locations {
        return modelBuilder!.outboundLocations!
    }
    
    
    public static func getDateComponents( date: NSDate ) -> ( dayComponent : NSDateComponents, nextDayComponent : NSDateComponents) {
        
        // Get YMD and HHMM from date
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dayComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear
                | NSCalendarUnit.CalendarUnitMonth
                | NSCalendarUnit.CalendarUnitDay
                | NSCalendarUnit.CalendarUnitHour
                | NSCalendarUnit.CalendarUnitMinute
                | NSCalendarUnit.CalendarUnitWeekday
            ,
            fromDate: date)
        
        // Get Next Day YMD
        var nextDay = NSDate( timeInterval:(24*60*60), sinceDate:date)
        var nextDayComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear
                | NSCalendarUnit.CalendarUnitMonth
                | NSCalendarUnit.CalendarUnitDay
                | NSCalendarUnit.CalendarUnitHour
                | NSCalendarUnit.CalendarUnitMinute
                | NSCalendarUnit.CalendarUnitWeekday
            ,
            fromDate: nextDay)

        return ( dayComponents, nextDayComponents )
    }
    
    func nextScheduleEntryFromTerminal( stop: RouteStop, terminalStop: RouteStop, date:NSDate ) -> Array<ScheduleEntry> {
        var components = ModelStore.getDateComponents(date)
        
        // Find all times from date
        var retDate = nextScheduleEntryFromTerminal(
            stop,
            terminalStop: terminalStop,
            year: components.dayComponent.year,
            month: components.dayComponent.month,
            day: components.dayComponent.day,
            hour: components.dayComponent.hour,
            min: components.dayComponent.minute)
        
        // Find all time from next day zero hour
        var retNextDay = nextScheduleEntryFromTerminal(
            stop,
            terminalStop: terminalStop,
            year: components.nextDayComponent.year,
            month: components.nextDayComponent.month,
            day: components.nextDayComponent.day,
            hour: 0,
            min: 0)
        
        // Merge them
        var ret = retDate
        for stopTime in retNextDay {
            ret.append(ScheduleEntry(stopTime: stopTime.stopTime, terminalTime: stopTime.terminalTime, nextDay: true))
        }

        ret.sort { (before, after) -> Bool in
            var rawTimeBefore = before.NextDay ? before.terminalTime.DepartureTime + 2400 : before.terminalTime.DepartureTime
            var rawTimeAfter = after.NextDay ? after.terminalTime.DepartureTime + 2400 : after.terminalTime.DepartureTime
            
            return rawTimeBefore < rawTimeAfter
        }
        
        return ret
    }
    
    func nextScheduleEntryToTerminal( stop: RouteStop, date:NSDate) -> Array<ScheduleEntry> {
        
        var components = ModelStore.getDateComponents(date)
        
        // Find all times from date
        var retDate = nextScheduleEntryToTerminal(
            stop,
            year: components.dayComponent.year,
            month: components.dayComponent.month,
            day: components.dayComponent.day,
            hour: components.dayComponent.hour,
            min: components.dayComponent.minute)
        
        // Find all time from next day zero hour
        var retNextDay = nextScheduleEntryToTerminal(
            stop,
            year: components.nextDayComponent.year,
            month: components.nextDayComponent.month,
            day: components.nextDayComponent.day,
            hour: 0,
            min: 0)
        
        // Merge them
        var ret = retDate
        for stopTime in retNextDay {
            var tomorrowTerminalStopTime = RouteStopTime(
                tripId: stopTime.terminalTime.TripId,
                arrivalTime: stopTime.terminalTime.ArrivalTime,
                departureTime: stopTime.terminalTime.DepartureTime,
                stopId: stopTime.terminalTime.StopId,
                sequence: stopTime.terminalTime.Sequence)
            ret.append(ScheduleEntry(stopTime: stopTime.stopTime, terminalTime: stopTime.terminalTime, nextDay: true))
        }
        
        ret.sort { (before, after) -> Bool in
            var rawTimeBefore = before.NextDay ? before.stopTime.DepartureTime + 2400 : before.stopTime.DepartureTime
            var rawTimeAfter = after.NextDay ? after.stopTime.DepartureTime + 2400 : after.stopTime.DepartureTime
            
            return rawTimeBefore < rawTimeAfter
        }
        
        return ret
    }
    
    private func nextScheduleEntryFromTerminal( stop: RouteStop, terminalStop: RouteStop, year: Int, month: Int, day: Int, hour: Int, min: Int ) -> Array<ScheduleEntry> {
        var ret = Array<ScheduleEntry>()
        
        // Find Service Id
        let hm = ( hour * 100 ) + min
        if let services = modelBuilder!.calendarDatesDictionary![ (year * 10000) + (month * 100) + day ] {
            for service in services {
                for trip in service.outboundTrips {
                    var destinationStopTime : RouteStopTime? = nil
                    var terminalStopTime : RouteStopTime? = nil
                    
                    for stopTime in trip.StopTimes {
                        
                        if stopTime.DepartureTime >= hm && stopTime.StopId == terminalStop.Identity {
                            terminalStopTime = stopTime
                        }
                        if stopTime.StopId == stop.Identity {
                            destinationStopTime = stopTime
                        }
                        
                        if destinationStopTime != nil && terminalStopTime != nil {

                            ret.append(ScheduleEntry(stopTime: stopTime, terminalTime: terminalStopTime!) )
                            destinationStopTime = nil
                            terminalStopTime = nil
                        }
                    }
                }
            }
        }
        return ret
    }
    
    private func nextScheduleEntryToTerminal( stop: RouteStop, year: Int, month: Int, day: Int, hour: Int, min: Int ) -> Array<ScheduleEntry> {
        var ret = Array<ScheduleEntry>()
        
        // Find Service Id
        let hm = ( hour * 100 ) + min
        if let services = modelBuilder!.calendarDatesDictionary![ (year * 10000) + (month * 100) + day ] {
            for service in services {
                for trip in service.inboundTrips {
                    var originStopTime : RouteStopTime? = nil
                    var terminalStopTime : RouteStopTime? = nil

                    for stopTime in trip.StopTimes {

                        if stopTime.StopId == stop.Identity {
                            originStopTime = stopTime
                        }
                        
                        if stopTime.StopId == modelBuilder?.inBoundTerminal?.Identity {
                            terminalStopTime = stopTime
                        }
                        
                        if originStopTime != nil && terminalStopTime != nil {
                            if originStopTime!.DepartureTime >= hm {
                                ret.append(ScheduleEntry(stopTime: originStopTime!, terminalTime: terminalStopTime!))
                            }
                        }
                    }
                }
            }
        }
        
        return ret
    }
    

    public static func getDate( year: Int, month: Int, day: Int, hour: Int, minute: Int ) -> NSDate {
        let dateAsString = "\(month)/\(day)/\(year), \(hour):\(minute)"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy, H:mm"
        return dateFormatter.dateFromString(dateAsString)!
    }
    
    public static func nextDay0hrX( date: NSDate ) -> NSDate {
        
        var nextDay = NSDate( timeInterval:(24*60*60), sinceDate:date )
        
        // Get YMD from date
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dayComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear
                | NSCalendarUnit.CalendarUnitMonth
                | NSCalendarUnit.CalendarUnitDay
            ,
            fromDate: nextDay)

        return getDate(dayComponents.year, month: dayComponents.month, day: dayComponents.day, hour: 0, minute: 0)
    }
    
    public static func timeAnalisys( date:NSDate, var rawTime: Int ) -> String {
        var prefix = ""
        var seconds = 0
        
        if rawTime >= 2400 {
            prefix = "Tomorrow "
            rawTime = rawTime - 2400
            seconds = seconds + 24 * 60 * 60
        }
        if rawTime >= 2400 {
            prefix = "Day After Tomorrow "
            rawTime = rawTime - 2400
            seconds = seconds + 24 * 60 * 60
        }
        
        // Get YMD and HHMM from date
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dayComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear
                | NSCalendarUnit.CalendarUnitMonth
                | NSCalendarUnit.CalendarUnitDay
            ,
            fromDate: date)

        let newDate = getDate(
            dayComponents.year,
            month: dayComponents.month,
            day: dayComponents.day,
            hour: Int(rawTime/100) ,
            minute: rawTime%100)
        var d =  NSDateFormatter.localizedStringFromDate(newDate, dateStyle: .NoStyle, timeStyle: .ShortStyle)

        return prefix + d
    }

    public static func findServiceDescription( weekDay: Int, rawTime: Int, route: String ) -> ( description: String, gate: String ) {
        
        var description = route
        var gate = ""
        
        switch weekDay {

        case 1, 7:         // Sunday, Saturday
            if (rawTime >= 600 && rawTime <= 1159) || ( rawTime < 100 )  {
                gate = "321"
            } else {
                gate = "81"
            }
            break;
        case 2, 3, 4, 5, 6:
            switch route {
                case "130":
                    if rawTime >= 1330 && rawTime <= 1640 {
                        gate = "322"
                        description += " - Express to Union Hill"
                    } else if rawTime >= 1700 && rawTime <= 1842 {
                        gate = "326"
                        description += " - Express to Union Hill"
                    } else if rawTime >= 1850 && rawTime <= 1900 {
                        gate = "322"
                        description += " - Express to Union Hill"
                    } else if rawTime >= 1912 && rawTime <= 2000 {
                        gate = "321"
                        description += " - Express to Union Hill"
                    }
                    break;
                case "132":
                    if rawTime >= 1700 && rawTime <= 1840 {
                        gate = "322"
                        description += " - Express to Gordons Corner/Via Freehold Center"
                    } else if rawTime >= 1545 && rawTime <= 1830 {
                        gate = "323"
                        description += " - Express to Gordons Corner/Raintree/Freehold Mall"
                    }
                    break;
                case "136":
                    if rawTime >= 1530 && rawTime <= 1900 {
                        gate = "321"
                        description  += " - Express to Freehold Mall"
                    }
                    break;
                case "139":
                    gate = "81"
                    if rawTime >= 500 && rawTime <= 559 {
                        gate = "81/321"
                    } else if rawTime >= 559 && rawTime <= 1500 {
                        gate = "321"
                    } else if rawTime >= 1512 && rawTime <= 1600 {
                        gate = "325"
                    } else if rawTime >= 1612 && rawTime <= 1900 {
                        gate = "324/325"
                    } else if rawTime >= 1900 && rawTime <= 1920 {
                        gate = "324"
                    } else if rawTime >= 1930 && rawTime <= 2000 {
                        gate = "322"
                    } else if rawTime >= 2010 && rawTime <= 2500 {
                        gate = "321"
                    }
                    break;
                default:
                    break;
            }
            break;
        default:
            NSLog("Weekday is \(weekDay)")
        }

        return ( description, gate )
    }
    
    
    
    public func loadFromConfig() {
        
        modelBuilder = configurationManager?.modelBuilder
        
        if let stopId = configurationManager!.toTerminalStop1 {
            self.toTerminalStop1 = modelBuilder!.stopsDictionary![configurationManager!.toTerminalStop1!]
        } else {
            self.toTerminalStop1 = nil
        }

        if let stopId = configurationManager!.toTerminalStop2 {
            self.toTerminalStop2 = modelBuilder!.stopsDictionary![configurationManager!.toTerminalStop2!]
        } else {
            self.toTerminalStop2 = nil
        }
        
        if let stopId = configurationManager!.toTerminalStop3 {
            self.toTerminalStop3 = modelBuilder!.stopsDictionary![configurationManager!.toTerminalStop3!]
        } else {
            self.toTerminalStop3 = nil
        }
        
        if let stopId = configurationManager!.fromTerminalStop1 {
            self.fromTerminalStop1 = modelBuilder!.stopsDictionary![configurationManager!.fromTerminalStop1!]
        } else {
            self.fromTerminalStop1 = nil
        }
        
        if let stopId = configurationManager!.fromTerminalStop2 {
            self.fromTerminalStop2 = modelBuilder!.stopsDictionary![configurationManager!.fromTerminalStop2!]
        } else {
            self.fromTerminalStop2 = nil
        }
        
        if let stopId = configurationManager!.fromTerminalStop3 {
            self.fromTerminalStop3 = modelBuilder!.stopsDictionary![configurationManager!.fromTerminalStop3!]
        } else {
            self.fromTerminalStop3 = nil
        }
    }
}