//
//  CalendarDate.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/12/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public enum DateException {
    case Working
    case NotWorking
}

public class CalendarDate {

    public let ServiceId : Int
    public let Year : Int
    public let Month : Int
    public let Day : Int
    
    public let Exception : DateException
    
    init( serviceId: Int, year: Int, month: Int, day: Int, exception: DateException ) {
        ServiceId = serviceId;
        Year = year
        Month = month
        Day = day
        
        Exception = exception
    }
    
    public static func FromRouteFetcher( ) -> Array<CalendarDate>  {
        
        let calendarDate = RouteFetcher.loadCalendarDates()
        
        var ret = calendarDate.map( {
            (let calendar ) -> CalendarDate in
            let serviceId = calendar[RouteFetcherConstants.Calendar.ServiceId] as! Int
            let ymd = calendar[RouteFetcherConstants.Calendar.Date] as! String
            let ex = calendar[RouteFetcherConstants.Calendar.ExceptionType] as! String
            
            let year = ymd.substringWithRange(Range(start: ymd.startIndex, end: advance(ymd.startIndex, 4)))
            let month = ymd.substringWithRange(Range(start: advance(ymd.startIndex, 4), end: advance(ymd.startIndex, 6)))
            let day = ymd.substringWithRange(Range(start: advance(ymd.startIndex, 6), end: advance(ymd.startIndex, 8)))
            
            var exception = (ex == "2") ? DateException.NotWorking : DateException.Working
            
            return CalendarDate( serviceId: serviceId, year: year.toInt()!, month: month.toInt()!, day: day.toInt()!, exception: exception )
            }
        )
        
        return ret;
        
    }

    
}