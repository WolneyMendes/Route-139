//
//  RouteTrip.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/12/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//
//


import Foundation

public class RouteTrip : NSObject, NSCoding {
    
    private struct PropertyKey {
        static let RouteIdKey = "RouteId"
        static let ServiceIdKey = "ServiceId"
        static let IdentityKey = "Identity"
        static let InboudKey = "Inboud"
        static let StopTimesKey = "StopTimes"
    }

    
    private var _stopTimes = Array<RouteStopTime>()

    public let RouteId : Int
    public let ServiceId : Int
    public let Identity : Int
    public let Inboud : Bool
    public var StopTimes : Array<RouteStopTime> { get { return _stopTimes } }
    
    init( routeId: Int, serviceId: Int, identity: Int, inboud: Bool ) {
        RouteId = routeId
        ServiceId = serviceId
        Identity = identity
        Inboud = inboud
        
        super.init()
    }
    
    private init( routeId: Int, serviceId: Int, identity: Int, inboud: Bool, stopTimes: Array<RouteStopTime> ) {
        RouteId = routeId
        ServiceId = serviceId
        Identity = identity
        Inboud = inboud
        _stopTimes = stopTimes
        
        super.init()
    }
    
    public func addStopTime( stopTime: RouteStopTime ) {
        _stopTimes.append(stopTime)
    }
    
    public static func FromRouteFetcher( ) -> Array<RouteTrip>  {
        return FromRouteFetcheArray( RouteFetcher.loadTrips() )
    }
    
    public static func FromRouteFetcheArray( trips: Array<Dictionary<String,AnyObject>>  ) -> Array<RouteTrip>  {
        
        
        var ret = trips.map( {
            (let trip ) -> RouteTrip in
            let routeId = trip[RouteFetcherConstants.Trip.RouteId] as! Int
            let serviceId = trip[RouteFetcherConstants.Trip.ServiceId] as! Int
            let identity = trip[RouteFetcherConstants.Trip.Identity] as! Int
            let direction = trip[RouteFetcherConstants.Trip.Direction] as! String

            
            return RouteTrip( routeId: routeId, serviceId: serviceId, identity: identity, inboud: direction == "0")
            }
        )
        
        return ret;
        
    }
    
    // MARK: Coding
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(RouteId, forKey: PropertyKey.RouteIdKey)
        aCoder.encodeInteger(ServiceId, forKey: PropertyKey.ServiceIdKey)
        aCoder.encodeInteger(Identity, forKey: PropertyKey.IdentityKey)
        aCoder.encodeBool(Inboud, forKey: PropertyKey.InboudKey)
        
        //aCoder.encodeObject(StopTimes, forKey: PropertyKey.StopTimesKey)
        aCoder.encodeInteger(self.StopTimes.count, forKey: PropertyKey.StopTimesKey)
        for index in 0 ..< self.StopTimes.count {
            aCoder.encodeObject( self.StopTimes[ index ] )
        }

    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        let routeId = aDecoder.decodeIntegerForKey(PropertyKey.RouteIdKey)
        let serviceId = aDecoder.decodeIntegerForKey(PropertyKey.ServiceIdKey)
        let identity = aDecoder.decodeIntegerForKey(PropertyKey.IdentityKey)
        let inbound = aDecoder.decodeBoolForKey(PropertyKey.InboudKey)
        
        //let stopTimes = aDecoder.decodeObjectForKey(PropertyKey.StopTimesKey) as? Array<RouteStopTime>
        let count = aDecoder.decodeIntegerForKey(PropertyKey.StopTimesKey)
        var stopTimes = [RouteStopTime]()
        for index in 0 ..< count {
            if var stopTime = aDecoder.decodeObject() as? RouteStopTime {
                stopTimes.append(stopTime)
            }
        }


        self.init(  routeId: routeId, serviceId: serviceId, identity: identity, inboud: inbound, stopTimes: stopTimes)
    }


}