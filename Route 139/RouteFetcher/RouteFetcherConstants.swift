//
//  RouteFetcherConstants.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public enum DayType :Int {
    case Weekday = 1
    case Tue2Fri = 2
    case Sat = 3
    case Sun = 4
    case Mon = 5
    case Weekend = 6
    case Holiday = 7
    case Mon2Thu = 8
}



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
    
    public static let ScheduleStopIdentity  = "stopidentity"
    public static let ScheduleLine          = "line"
    public static let ScheduleHHMM          = "time"
    public static let ScheduleDateType      = "datetype"
    public static let ScheduleTripNumber    = "tripnum"
    public static let ScheduleTripDirection = "tripdirection"
    
}

