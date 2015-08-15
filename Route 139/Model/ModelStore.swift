//
//  ModelStore.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/8/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

class ModelStore {
    
    private static var instance : ModelStore = {
        var stops = RouteStop.FromRouteFetcher()
        var calendarDates = CalendarDate.FromRouteFetcher()
        var trips = RouteTrip.FromRouteFetcher()
        var stopTimes = RouteStopTime.FromRouteFetcher()
        
        var i = ModelStore(stops: stops, calendarDates: calendarDates, trips: trips, stopTimes: stopTimes)
        
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
    
    private init( stops: Array<RouteStop>, calendarDates: Array<CalendarDate>, trips: Array<RouteTrip>, stopTimes: Array<RouteStopTime> ) {
        
        // Stops
        self.stops = stops
        var stopsDictionary = Dictionary<Int,RouteStop>()
        for stop in stops {
            stopsDictionary[stop.Identity] = stop
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
    
    private func getDateComponents( date: NSDate ) -> ( dayComponent : NSDateComponents, nextDayComponent : NSDateComponents) {
        
        // Get YMD and HHMM from date
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dayComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear
                | NSCalendarUnit.CalendarUnitMonth
                | NSCalendarUnit.CalendarUnitDay
                | NSCalendarUnit.CalendarUnitHour
                | NSCalendarUnit.CalendarUnitMinute
            ,
            fromDate: date)
        
        // Get Nexte Day YMD
        var nextDay = NSDate( timeInterval:(24*60*60), sinceDate:date)
        var nextDayComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear
                | NSCalendarUnit.CalendarUnitMonth
                | NSCalendarUnit.CalendarUnitDay
            ,
            fromDate: nextDay)

        return ( dayComponents, nextDayComponents )
    }
    
    func nextScheduleEntryFromTerminal( stop: RouteStop, terminalStop: RouteStop, date:NSDate ) -> Array<RouteStopTime> {
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
            var tomorrowStopTime = RouteStopTime(
                tripId: stopTime.TripId,
                arrivalTime: stopTime.ArrivalTime + 2400,
                departureTime: stopTime.DepartureTime + 2400,
                stopId: stopTime.StopId,
                sequence: stopTime.Sequence)
            ret.append(tomorrowStopTime)
        }

        ret.sort { (before, after) -> Bool in
            return before.DepartureTime < after.DepartureTime
        }
        
        return ret
    }
    
    func nextScheduleEntryToTerminal( stop: RouteStop, date:NSDate) -> Array<RouteStopTime> {
        
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
            var tomorrowStopTime = RouteStopTime(
                tripId: stopTime.TripId,
                arrivalTime: stopTime.ArrivalTime + 2400,
                departureTime: stopTime.DepartureTime + 2400,
                stopId: stopTime.StopId,
                sequence: stopTime.Sequence)
            ret.append(tomorrowStopTime)
        }
        
        ret.sort { (before, after) -> Bool in
            return before.DepartureTime < after.DepartureTime
        }
        
        return ret
    }
    
    func nextScheduleEntryFromTerminal( stop: RouteStop, terminalStop: RouteStop, year: Int, month: Int, day: Int, hour: Int, min: Int ) -> Array<RouteStopTime> {
        var ret = Array<RouteStopTime>()
        
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
                            ret.append(terminalStopTime!)
                        }
                    }
                }
            }
        }
        return ret
    }
    
    func nextScheduleEntryToTerminal( stop: RouteStop, year: Int, month: Int, day: Int, hour: Int, min: Int ) -> Array<RouteStopTime> {
        var ret = Array<RouteStopTime>()
        
        // Find Service Id
        let hm = ( hour * 100 ) + min
        if let services = calendarDatesDictionary[ (year * 10000) + (month * 100) + day ] {
            for service in services {
                for trip in service.inboundTrips {
                    for stopTime in trip.StopTimes {
                        if stopTime.StopId == stop.Identity {
                            if stopTime.DepartureTime >= hm {
                                ret.append(stopTime)
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


}