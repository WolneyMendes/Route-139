//
//  ModelStore.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/8/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class ModelStore {
    
    private static var instance : ModelStore = {
        var routes = Route.FromRouteFetcher()
        var stops = RouteStop.FromRouteFetcher()
        var calendarDates = CalendarDate.FromRouteFetcher()
        var trips = RouteTrip.FromRouteFetcher()
        var stopTimes = RouteStopTime.FromRouteFetcher()
        
        var i = ModelStore(routes: routes, stops: stops, calendarDates: calendarDates, trips: trips, stopTimes: stopTimes)
        
        i.inboundLocations = i.locationsToTerminal()
        i.outboundLocations = i.locationsFromTerminal()
        
        return i;
        }()
   
    class var sharedInstance: ModelStore {
        return instance
    }
    
    var toTerminalStop1   : RouteStop? = nil
    var toTerminalStop2   : RouteStop? = nil
    var toTerminalStop3   : RouteStop? = nil
    
    var fromTerminalStop1 : RouteStop? = nil
    var fromTerminalStop2 : RouteStop? = nil
    var fromTerminalStop3 : RouteStop? = nil
    
    var outboundTerminal : RouteStop? = nil
    var inboundTerminal : RouteStop? = nil
    
    
    private let routes           : Array<Route>
    private let routesDictionary : Dictionary<Int,Route>
    
    private let stops           : Array<RouteStop>
    private let stopsDictionary : Dictionary<Int,RouteStop>
    
    private let calendarDates : Array<CalendarDate>
    private let calendarDatesDictionary : Dictionary<Int,Array<Service>>
    private let serviceDictionary : Dictionary<Int,Service>
    
    private let trips           : Array<RouteTrip>
    private let inBoundTrip     : Array<RouteTrip>
    private let outBoundTrip    : Array<RouteTrip>
    private let tripsDictionary : Dictionary<Int,RouteTrip>
    
    private let stopTimes     : Array<RouteStopTime>
    
    private var inboundLocations = Locations()
    private var outboundLocations = Locations()
    
    // MARK: - Initializer
    
    private init( routes: Array<Route>,  stops: Array<RouteStop>, calendarDates: Array<CalendarDate>, trips: Array<RouteTrip>, stopTimes: Array<RouteStopTime> ) {
        
        // Routes
        self.routes = routes
        var routesDictionary = Dictionary<Int, Route>()
        for route in routes {
            routesDictionary[route.Identity] = route
        }
        self.routesDictionary = routesDictionary
        
        // Stops
        self.stops = stops
        var stopsDictionary = Dictionary<Int,RouteStop>()
        for stop in stops {
            stopsDictionary[stop.Identity] = stop
            
            NSLog("------------------ Port Authority term stop is hard coded!!" )
            if stop.Identity == AppDelegate.Constants.OutBoundPortAuthorityStop {
                outboundTerminal = stop
            }
            
            if stop.Identity == AppDelegate.Constants.InBoundPortAuthorityStop {
                inboundTerminal = stop
            }
        }
        self.stopsDictionary = stopsDictionary
        
        // Calendar Dates
        self.calendarDates = calendarDates
        var calendarDatesDictionary = Dictionary<Int,Array<Service>>()
        var serviceDictionary = Dictionary<Int,Service>()
        for calendarDate in calendarDates {
            
            // If service does not exist then create it!
            if serviceDictionary[calendarDate.ServiceId] == nil {
                serviceDictionary[calendarDate.ServiceId] = Service(identity: calendarDate.ServiceId)
            }

            let idx = (calendarDate.Year * 10000) + (calendarDate.Month * 100) + calendarDate.Day
            if calendarDatesDictionary[ idx ] == nil {
                // Fist time we see this date... create an empty array of service for this day.
                calendarDatesDictionary[ idx ] = Array<Service>()
            }
            calendarDatesDictionary[ idx ]!.append(serviceDictionary[calendarDate.ServiceId]!)
        }
        self.calendarDatesDictionary = calendarDatesDictionary
        
        // Trips
        self.trips = trips
        var inBoundTrip = Array<RouteTrip>()
        var outBoundTrip = Array<RouteTrip>()
        var tripsDictionary = Dictionary<Int,RouteTrip>()
        for trip in trips {
            tripsDictionary[trip.Identity] = trip
            if( trip.Inboud ){
                inBoundTrip.append(trip)
            } else {
                outBoundTrip.append(trip)
            }
            serviceDictionary[trip.ServiceId]!.addTrip(trip)
        }
        self.inBoundTrip = inBoundTrip
        self.outBoundTrip = outBoundTrip
        self.tripsDictionary = tripsDictionary
        self.serviceDictionary = serviceDictionary
        
        // Stop Times
        var stopTimesSorted = stopTimes
        // WFM Not sure if I need the sort
        stopTimesSorted.sort({ (before, after) -> Bool in
            return before.ArrivalTime < after.ArrivalTime
        })
        for stopTime in stopTimes {
            if let trip = tripsDictionary[stopTime.TripId] {
                trip.addStopTime(stopTime)
            }
        }
        self.stopTimes = stopTimesSorted
    }
    
    func getRoute ( fromTrip: Int ) -> Route? {
        return routesDictionary[tripsDictionary[fromTrip]!.RouteId]
    }
    
    // MARK: - Need Work
    
    func getLocationsToTerminal() -> Locations {
        return inboundLocations;
    }
    
    func getLocationsFromTerminal() -> Locations {
        return outboundLocations
    }
    
    // Has to be done in a different way
    private func locationsToTerminal() -> Locations {
        var locations = Locations()

        for trip in inBoundTrip {
            if trip.Inboud {
                // find all the stops for this trip
                for stopTime in stopTimes {
                    if( stopTime.TripId == trip.Identity ) {
                        locations.addStop( stopsDictionary[stopTime.StopId]! )
                    }
                }
            } else {
                NSLog("Outbound trip")
            }
        }
        
        return locations
    }
    
    // Has to be done in a different way
    private func locationsFromTerminal() -> Locations {
        var locations = Locations()
        
        for trip in outBoundTrip {
            if !trip.Inboud {
                // find all the stops for this trip
                for stopTime in stopTimes {
                    if( stopTime.TripId == trip.Identity ) {
                        locations.addStop( stopsDictionary[stopTime.StopId]! )
                    }
                }
            } else {
                NSLog("Inbound trip")
            }
        }
        
        return locations
    }
    
    public func getDateComponents( date: NSDate ) -> ( dayComponent : NSDateComponents, nextDayComponent : NSDateComponents) {
        
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
        var components = getDateComponents(date)
        
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
        
        var components = getDateComponents(date)
        
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
        if let services = calendarDatesDictionary[ (year * 10000) + (month * 100) + day ] {
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
        if let services = calendarDatesDictionary[ (year * 10000) + (month * 100) + day ] {
            for service in services {
                for trip in service.inboundTrips {
                    var originStopTime : RouteStopTime? = nil
                    var terminalStopTime : RouteStopTime? = nil

                    for stopTime in trip.StopTimes {

                        if stopTime.StopId == stop.Identity {
                            originStopTime = stopTime
                        }
                        
                        if stopTime.StopId == inboundTerminal?.Identity {
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
    
    func save() {
        
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
        
        var description = ""
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
                        description = "Express to Union Hill"
                    } else if rawTime >= 1700 && rawTime <= 1842 {
                        gate = "326"
                        description = "Express to Union Hill"
                    } else if rawTime >= 1850 && rawTime <= 1900 {
                        gate = "322"
                        description = "Express to Union Hill"
                    } else if rawTime >= 1912 && rawTime <= 2000 {
                        gate = "321"
                        description = "Express to Union Hill"
                    }
                    break;
                case "132":
                    if rawTime >= 1700 && rawTime <= 1840 {
                        gate = "322"
                        description = "Express to Gordons Corner/Via Freehold Center"
                    } else if rawTime >= 1545 && rawTime <= 1830 {
                        gate = "321"
                        description = "Express to Gordons Corner/Raintree/Freehold Mall"
                    }
                    break;
                case "136":
                    if rawTime >= 1530 && rawTime <= 1900 {
                        gate = "321"
                        description  = "Express to Freehold Mall"
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
    

}