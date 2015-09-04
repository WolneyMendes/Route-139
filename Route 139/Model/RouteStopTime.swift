//
//  RouteStopTime.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/12/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class RouteStopTime : NSObject, NSCoding {

    private struct PropertyKey {
        static let TripIdKey        = "TripId"
        static let ArrivalTimeKey   = "ArrivalTime"
        static let DepartureTimeKey = "DepartureTime"
        static let StopIdKey        = "StopId"
        static let SequenceKey      = "Sequence"
    }

    public let TripId : Int
    public let ArrivalTime : Int
    public let DepartureTime : Int
    public let StopId : Int
    public let Sequence : Int
    
    init( tripId: Int, arrivalTime: Int, departureTime: Int, stopId: Int, sequence: Int) {
        TripId = tripId
        ArrivalTime = arrivalTime
        DepartureTime = departureTime
        StopId = stopId
        Sequence = sequence
        
        super.init()
    }
    
    public static func FromRouteFetcher( ) -> Array<RouteStopTime>  {
        return FromRouteFetcheArray(RouteFetcher.loadStopTimes())
    }
    
    public static func FromRouteFetcheArray( stopTimes: Array<Dictionary<String,AnyObject>> ) -> Array<RouteStopTime>  {
        
        let ret = stopTimes.map( {
            (let stopTime) -> RouteStopTime in
            let sequence = stopTime[RouteFetcherConstants.StopTime.Sequence] as! Int
            let stopId = stopTime[RouteFetcherConstants.StopTime.StopId] as! Int
            let tripId = stopTime[RouteFetcherConstants.StopTime.TripId] as! Int
            
            let arrivalTimeString = stopTime[RouteFetcherConstants.StopTime.ArrivalTime] as! String
            let departureTimeString = stopTime[RouteFetcherConstants.StopTime.DepartureTime] as! String
            
            let arrivalHourString = arrivalTimeString.substringWithRange(
                Range(
                    start: arrivalTimeString.startIndex,
                    end: advance(arrivalTimeString.startIndex, 2))
            )
            let arrivalMinuteString = arrivalTimeString.substringWithRange(
                Range(
                    start: advance(arrivalTimeString.startIndex, 3),
                    end: advance(arrivalTimeString.startIndex, 5))
            )
            
            let departureHourString = departureTimeString.substringWithRange(
                Range(
                    start: departureTimeString.startIndex,
                    end: advance(departureTimeString.startIndex, 2))
            )
            let departureMinuteString = departureTimeString.substringWithRange(
                Range(
                    start: advance(departureTimeString.startIndex, 3),
                    end: advance(departureTimeString.startIndex, 5))
            )

            
            return RouteStopTime(
                tripId: tripId,
                arrivalTime: arrivalHourString.toInt()! * 100 + arrivalMinuteString.toInt()!,
                departureTime: departureHourString.toInt()! * 100 + departureMinuteString.toInt()!,
                stopId: stopId,
                sequence: sequence)
            }
        )
        
        return ret;
        
    }

    // MARK: Coding
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(TripId, forKey: PropertyKey.TripIdKey)
        aCoder.encodeInteger(ArrivalTime, forKey: PropertyKey.ArrivalTimeKey)
        aCoder.encodeInteger(DepartureTime, forKey: PropertyKey.DepartureTimeKey)
        aCoder.encodeInteger(StopId, forKey: PropertyKey.StopIdKey)
        aCoder.encodeInteger(Sequence, forKey: PropertyKey.SequenceKey)
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        let tripId = aDecoder.decodeIntegerForKey(PropertyKey.TripIdKey)
        let arrivalTime = aDecoder.decodeIntegerForKey(PropertyKey.ArrivalTimeKey)
        let departureTime = aDecoder.decodeIntegerForKey(PropertyKey.DepartureTimeKey)
        let StopId = aDecoder.decodeIntegerForKey(PropertyKey.StopIdKey)
        let sequence = aDecoder.decodeIntegerForKey(PropertyKey.SequenceKey)
        
        self.init( tripId: tripId, arrivalTime: arrivalTime, departureTime: departureTime, stopId: StopId, sequence: sequence)
    }

}