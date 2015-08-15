//
//  RouteStopTime.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/12/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class RouteStopTime {
    
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
    }
    
    public static func FromRouteFetcher( ) -> Array<RouteStopTime>  {
        
        var stopTimes = RouteFetcher.loadStopTimes()
        
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

    
}