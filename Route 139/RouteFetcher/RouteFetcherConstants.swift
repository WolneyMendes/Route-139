//
//  RouteFetcherConstants.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public struct RouteFetcherConstants {
    
    public static let CalendarJsonPath   = "139Calendar_dates"
    public static let TripsJsonPath      = "139Trips"
    public static let StopsJsonPath      = "139Stops"
    public static let StopTimesJsonPath  = "139StopTimes"
    public static let RoutesJsonPath     = "139Routes"

    public struct Route {
        public static let Name        = "route_short_name"
        public static let Identity    = "route_id"
    }
    
    public struct Stop {
        public static let Name        = "stop_name"
        public static let Code        = "stop_code"
        public static let Identity    = "stop_id"
        public static let Lat         = "stop_lat"
        public static let Lon         = "stop_lon"
        public static let Location    = "stop_location"
    }
    
    public struct StopTime {
        public static let TripId        = "trip_id"
        public static let ArrivalTime   = "arrival_time"
        public static let DepartureTime = "departure_time"
        public static let StopId        = "stop_id"
        public static let Sequence      = "stop_sequence"
    }
    
    public struct Calendar {
        public static let ServiceId     = "service_id"
        public static let Date          = "date"
        public static let ExceptionType = "exception_type"
    }
    
    public struct Trip {
        public static let RouteId   = "route_id"
        public static let ServiceId = "service_id"
        public static let Identity  = "trip_id"
        public static let Direction = "direction_id"
    }
    
    public struct Timestamp {
        public static let Stops = "stops"
        public static let StopTimes = "stopTimes"
        public static let Routes = "routes"
        public static let Trips = "trips"
        public static let Calendar = "calendar_dates"
        public static let Terminal = "terminal"
    }
    
    public struct Terminal {
        public static let Inbound = "inbound"
        public static let OutBound = "outbound"
    }

}

