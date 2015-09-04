//
//  ModelBuilder.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/31/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class ModelBuilder : NSObject, NSCoding {
    
    private struct PropertyKey {
        static let timestampKey = "timestamp"
        static let routesDictionaryKey = "routesDictionary"
        static let stopsDictionaryKey = "stopsDictionary"
        static let calendarDatesDictionaryKey = "calendarDatesDictionary"
        static let serviceDictionaryKey = "serviceDictionary"
        static let inBoundTripKey = "inBoundTrip"
        static let outBoundTripKey = "outBoundTrip"
        static let tripsDictionaryKey = "tripsDictionary"
        static let stopTimesKey = "stopTimes"
        static let inboundLocationsKey = "inboundLocations"
        static let outboundLocationsKey = "outboundLocations"
        static let inboundTerminalKey = "inboundTerminal"
        static let outboundTerminalKey = "outboundTerminal"
    }
    
    public var routesDictionary : Dictionary<Int, Route>?
    public var stopsDictionary : Dictionary<Int,RouteStop>?
    public var calendarDatesDictionary : Dictionary<Int,ServiceArray>?
    public var serviceDictionary : Dictionary<Int,Service>?
    public var inBoundTrip : Array<RouteTrip>?
    public var outBoundTrip : Array<RouteTrip>?
    public var tripsDictionary : Dictionary<Int,RouteTrip>?
    private var stopTimes : Array<RouteStopTime>?
    public var inboundLocations : Locations?
    public var outboundLocations : Locations?
    
    public var outBoundTerminal : RouteStop?
    public var inBoundTerminal : RouteStop?
    
    public  let timestamp : Int
    private let terminals : Dictionary<String,Int>
    private let allCalendar: Array<CalendarDate>
    private let allRoutes: Array<Route>
    private let allStops: Array<RouteStop>
    private let allStopTime: Array<RouteStopTime>
    private let allTrips: Array<RouteTrip>

    private var cancel  = false
    
    private init(
        timeStamp: Int,
        routesDictionary: Dictionary<Int, Route>,
        stopsDictionary : Dictionary<Int,RouteStop>,
        calendarDatesDictionary : Dictionary<Int,ServiceArray>,
        serviceDictionary : Dictionary<Int,Service>,
        inBoundTrip : Array<RouteTrip>,
        outBoundTrip : Array<RouteTrip>,
        tripsDictionary : Dictionary<Int,RouteTrip>,
        stopTimes : Array<RouteStopTime>,
        inboundLocations : Locations,
        outboundLocations : Locations,
        inboundTerminal: RouteStop,
        outboundTerminal: RouteStop
        ) {
            self.timestamp = timeStamp
            self.allCalendar = Array<CalendarDate>()
            self.allRoutes = Array<Route>()
            self.allStops = Array<RouteStop>()
            self.allStopTime = Array<RouteStopTime>()
            self.allTrips = Array<RouteTrip>()
            self.terminals = Dictionary<String,Int>()
            
            self.routesDictionary = routesDictionary
            self.stopsDictionary = stopsDictionary
            self.calendarDatesDictionary = calendarDatesDictionary
            self.serviceDictionary = serviceDictionary
            self.inBoundTrip = inBoundTrip
            self.outBoundTrip = outBoundTrip
            self.tripsDictionary = tripsDictionary
            self.stopTimes = stopTimes
            self.inboundLocations = inboundLocations
            self.outboundLocations = outboundLocations
            self.inBoundTerminal = inboundTerminal
            self.outBoundTerminal = outboundTerminal

            super.init()
            

    }
    
    public init( configManager: ConfigurationManager) {
        
        self.timestamp = 0
        self.terminals = [ "outbound": 3511, "inbound": 43274 ]
        self.allCalendar = CalendarDate.FromRouteFetcher()
        self.allRoutes = Route.FromRouteFetcher()
        self.allStops = RouteStop.FromRouteFetcher()
        self.allStopTime = RouteStopTime.FromRouteFetcher()
        self.allTrips = RouteTrip.FromRouteFetcher()
        
        super.init()
        
        self.startSync()
    
    }
    
    public init(
        timestamp : Int,
        terminals: Dictionary<String,Int>,
        allCalendar: Array<CalendarDate>,
        allRoutes: Array<Route>,
        allStops: Array<RouteStop>,
        allStopTime: Array<RouteStopTime>,
        allTrips: Array<RouteTrip>
        ) {
            self.timestamp = timestamp
            self.terminals = terminals
            self.allCalendar = allCalendar
            self.allRoutes = allRoutes
            self.allStops = allStops
            self.allStopTime = allStopTime
            self.allTrips = allTrips
            
            super.init()
    }
    
    public func startSync() {
        
        if cancel {
            return;
        }
        buildRoutes()
        if cancel {
            return;
        }
        buildStops()
        if cancel {
            return;
        }
        buildCalendar()
        if cancel {
            return;
        }
        buildTrips()
        if cancel {
            return;
        }
        buildStopTimes()
        if cancel {
            return;
        }
        
        inboundLocations = self.locationsToTerminal()
        if cancel {
            return;
        }
        outboundLocations = self.locationsFromTerminal()
        
        inBoundTerminal = stopsDictionary![terminals[RouteFetcherConstants.Terminal.Inbound]!]!
        outBoundTerminal = stopsDictionary![terminals[RouteFetcherConstants.Terminal.OutBound]!]!

    }
    
    public func startAsync( callback: () ->Void ) {
        var queueToDispatch = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        var main_queue = dispatch_get_main_queue()
        
        dispatch_async(queueToDispatch) {
            
            self.startSync()
            
            dispatch_async(main_queue) {
                callback()
            }
            
        }
        
    }
    
    public func cancelAsync() {
        cancel = true
    }
    
    private func buildRoutes() {
        // Routes
        var routesDictionary = Dictionary<Int, Route>()
        for route in allRoutes {
            routesDictionary[route.Identity] = route
        }
        self.routesDictionary = routesDictionary
    }
    
    private func buildStops() {
        // Stops
        var stopsDictionary = Dictionary<Int,RouteStop>()
        for stop in allStops {
            stopsDictionary[stop.Identity] = stop
        }
        self.stopsDictionary = stopsDictionary
    }
    
    private func buildCalendar() {
        // Calendar Dates
        var calendarDatesDictionary = Dictionary<Int,ServiceArray>()
        var serviceDictionary = Dictionary<Int,Service>()
        for calendarDate in allCalendar {
            
            // If service does not exist then create it!
            if serviceDictionary[calendarDate.ServiceId] == nil {
                serviceDictionary[calendarDate.ServiceId] = Service(identity: calendarDate.ServiceId)
            }
            
            let idx = (calendarDate.Year * 10000) + (calendarDate.Month * 100) + calendarDate.Day
            if calendarDatesDictionary[ idx ] == nil {
                // Fist time we see this date... create an empty array of service for this day.
                calendarDatesDictionary[ idx ] = ServiceArray()
            }
            calendarDatesDictionary[ idx ]!.append(serviceDictionary[calendarDate.ServiceId]!)
        }
        self.calendarDatesDictionary = calendarDatesDictionary
        self.serviceDictionary = serviceDictionary
    }
    
    private func buildTrips() {
        // Trips
        var inBoundTrip = Array<RouteTrip>()
        var outBoundTrip = Array<RouteTrip>()
        var tripsDictionary = Dictionary<Int,RouteTrip>()

        for trip in allTrips {
            tripsDictionary[trip.Identity] = trip
            if( trip.Inboud ){
                inBoundTrip.append(trip)
            } else {
                outBoundTrip.append(trip)
            }
            serviceDictionary![trip.ServiceId]!.addTrip(trip)
        }
        self.inBoundTrip = inBoundTrip
        self.outBoundTrip = outBoundTrip
        self.tripsDictionary = tripsDictionary
    }
    
    private func buildStopTimes() {
        // Stop Times
        var stopTimesSorted = allStopTime
        // WFM Not sure if I need the sort
        stopTimesSorted.sort({ (before, after) -> Bool in
            return before.ArrivalTime < after.ArrivalTime
        })
        for stopTime in allStopTime {
            if let trip = tripsDictionary![stopTime.TripId] {
                trip.addStopTime(stopTime)
            }
        }
        self.stopTimes = stopTimesSorted
    }
    
    // Has to be done in a different way
    private func locationsToTerminal() -> Locations {
        var locations = Locations()
        
        for trip in inBoundTrip! {
            if trip.Inboud {
                // find all the stops for this trip
                for stopTime in stopTimes! {
                    if( stopTime.TripId == trip.Identity ) {
                        locations.addStop( stopsDictionary![stopTime.StopId]! )
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
        
        for trip in outBoundTrip! {
            if !trip.Inboud {
                // find all the stops for this trip
                for stopTime in stopTimes! {
                    if( stopTime.TripId == trip.Identity ) {
                        locations.addStop( stopsDictionary![stopTime.StopId]! )
                    }
                }
            } else {
                NSLog("Inbound trip")
            }
        }
        
        return locations
    }
    
    // MARK: NSCoder
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.timestamp, forKey: PropertyKey.timestampKey)
        aCoder.encodeObject(self.routesDictionary, forKey: PropertyKey.routesDictionaryKey)
        aCoder.encodeObject(self.stopsDictionary, forKey: PropertyKey.stopsDictionaryKey)
        aCoder.encodeObject(self.calendarDatesDictionary, forKey: PropertyKey.calendarDatesDictionaryKey)
        aCoder.encodeObject(self.serviceDictionary, forKey: PropertyKey.serviceDictionaryKey)
        
        
        aCoder.encodeInteger(self.inBoundTrip!.count, forKey: PropertyKey.inBoundTripKey)
        for index in 0 ..< self.inBoundTrip!.count {
            aCoder.encodeObject( self.inBoundTrip![ index ] )
        }
        
        aCoder.encodeInteger(self.outBoundTrip!.count, forKey: PropertyKey.outBoundTripKey)
        for index in 0 ..< self.outBoundTrip!.count {
            aCoder.encodeObject( self.outBoundTrip![ index ] )
        }
        
        aCoder.encodeObject(self.tripsDictionary, forKey: PropertyKey.tripsDictionaryKey)
        
        aCoder.encodeInteger(self.stopTimes!.count, forKey: PropertyKey.stopTimesKey)
        for index in 0 ..< self.stopTimes!.count {
            aCoder.encodeObject( self.stopTimes![ index ] )
        }
        
        
        aCoder.encodeObject(self.inboundLocations, forKey: PropertyKey.inboundLocationsKey)
        aCoder.encodeObject(self.outboundLocations, forKey: PropertyKey.outboundLocationsKey)
        aCoder.encodeObject(self.inBoundTerminal, forKey: PropertyKey.inboundTerminalKey)
        aCoder.encodeObject(self.outBoundTerminal, forKey: PropertyKey.outboundTerminalKey)
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        let timeStamp = aDecoder.decodeIntegerForKey(PropertyKey.timestampKey)
        let routesDictionary = aDecoder.decodeObjectForKey(PropertyKey.routesDictionaryKey) as? Dictionary<Int, Route>
        let stopsDictionary = aDecoder.decodeObjectForKey(PropertyKey.stopsDictionaryKey) as? Dictionary<Int,RouteStop>
        let calendarDatesDictionary = aDecoder.decodeObjectForKey(PropertyKey.calendarDatesDictionaryKey) as? Dictionary<Int,ServiceArray>
        let serviceDictionary = aDecoder.decodeObjectForKey(PropertyKey.serviceDictionaryKey) as? Dictionary<Int,Service>
        
        let iboundTripCount = aDecoder.decodeIntegerForKey(PropertyKey.inBoundTripKey)
        var iBoundTrip = [RouteTrip]()
        for index in 0 ..< iboundTripCount {
            if var routeTrip = aDecoder.decodeObject() as? RouteTrip {
                iBoundTrip.append(routeTrip)
            }
        }
        
        //let outBoundTrip = aDecoder.decodeObjectForKey(PropertyKey.outBoundTripKey) as? Array<RouteTrip>
        let oboundTripCount = aDecoder.decodeIntegerForKey(PropertyKey.outBoundTripKey)
        var oBoundTrip = [RouteTrip]()
        for index in 0 ..< oboundTripCount {
            if var routeTrip = aDecoder.decodeObject() as? RouteTrip {
                oBoundTrip.append(routeTrip)
            }
        }
        
        let tripsDictionary = aDecoder.decodeObjectForKey(PropertyKey.tripsDictionaryKey) as? Dictionary<Int,RouteTrip>
        
        
        //let stopTimes = aDecoder.decodeObjectForKey(PropertyKey.stopTimesKey) as? Array<RouteStopTime>
        let stopTimesCount = aDecoder.decodeIntegerForKey(PropertyKey.stopTimesKey)
        var stopTimes = [RouteStopTime]()
        for index in 0 ..< stopTimesCount {
            if var stopTime = aDecoder.decodeObject() as? RouteStopTime {
                stopTimes.append(stopTime)
            }
        }
        
        
        let inboundLocations = aDecoder.decodeObjectForKey(PropertyKey.inboundLocationsKey) as? Locations
        let outboundLocations = aDecoder.decodeObjectForKey(PropertyKey.outboundLocationsKey) as? Locations
        let inboundTerminal = aDecoder.decodeObjectForKey(PropertyKey.inboundTerminalKey) as? RouteStop
        let outboundTerminal = aDecoder.decodeObjectForKey(PropertyKey.outboundTerminalKey) as? RouteStop

        
        self.init(
            timeStamp: timeStamp,
            routesDictionary: routesDictionary!,
            stopsDictionary : stopsDictionary!,
            calendarDatesDictionary : calendarDatesDictionary!,
            serviceDictionary : serviceDictionary!,
            inBoundTrip : iBoundTrip,
            outBoundTrip : oBoundTrip,
            tripsDictionary : tripsDictionary!,
            stopTimes : stopTimes,
            inboundLocations : inboundLocations!,
            outboundLocations : outboundLocations!,
            inboundTerminal: inboundTerminal!,
            outboundTerminal : outboundTerminal!
        )
        
    }
}
