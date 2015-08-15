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
    
    var fromTerminalStop3 : RouteStop? = nil
    
    // MARK: - Initializer
    
    private init( stops: Array<RouteStop>, calendarDates: Array<CalendarDate>, trips: Array<RouteTrip>, stopTimes: Array<RouteStopTime> ) {
        
        // Stops
        self.stops = stops
        var stopsDictionary = Dictionary<Int,RouteStop>()
        for stop in stops {
            stopsDictionary[stop.Identity] = stop
            if stop.Name.rangeOfString("SCHI") != nil
            {
                toTerminalStop1 = stop
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
            if trip.ServiceId == 32 {
                NSLog("Service 32 trip \(trip.Identity)")
            }
            serviceDictionary[trip.ServiceId]!.addTrip(trip)
        }
        self.inBoundTrip = inBoundTrip
        self.outBoundTrip = outBoundTrip
        self.tripsDictionary = tripsDictionary
        self.serviceDictionary = serviceDictionary
        
        // Stop Times
        var stopTimesSorted = stopTimes
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
    
    // Has to be done in a different way
    func locationsToTerminal() -> Locations {
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
    func locationsFromTerminal() -> Locations {
        var locations = Locations()
        
        for trip in inBoundTrip {
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
    
    func nextScheduleEntry( toTerminal: Bool, stop: RouteStop, numberOfEntries:Int, now: NSDate) -> Array<RouteStopTime> {
        var ret = Array<RouteStopTime>()
        
        // Find Service Id
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components(
            NSCalendarUnit.CalendarUnitYear
                | NSCalendarUnit.CalendarUnitMonth
                | NSCalendarUnit.CalendarUnitDay
                | NSCalendarUnit.CalendarUnitHour
                | NSCalendarUnit.CalendarUnitMinute
            ,
            fromDate: now)
        let hm = ( components.hour * 100 ) + components.minute
        if let services = calendarDatesDictionary[ (components.year * 10000) + (components.month * 100) + components.day ] {
            for service in services {
                let trips = toTerminal ? service.inboundTrips : service.outboundTrips
                for trip in trips {
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
        
        ret.sort { (before, after) -> Bool in
            before.DepartureTime < after.DepartureTime
        }
        
        return ret
    }
    
    
    func save() {
        
    }


}