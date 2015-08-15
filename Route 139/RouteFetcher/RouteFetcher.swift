//
//  RouteFetcher.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

// Day Type
// 1 = Weekday
// 2 = Tue-Fri
// 3 = Sat
// 4 = Sun
// 5 = Mon
// 6 = Weekend
// 7 = Holiday
// 8 = Mon-Thu

// Trip Direction
// 0 to NYC
// 1 from NYC

//var bundle = NSBundle.mainBundle()
//var calendarPath = bundle.pathForResource("calendar_dates", ofType: "json")
//var tripsPath = bundle.pathForResource("139Trips", ofType: "json")
//var stopsPath = bundle.pathForResource("139Stops", ofType: "json")
//var stopsTimesPath = bundle.pathForResource("139StopTimes", ofType: "json")
//var routesPath = bundle.pathForResource("139Routes", ofType: "json")
//var x = String(contentsOfFile: calendarPath!, encoding: NSUTF8StringEncoding, error: nil)
//x = String(contentsOfFile: tripsPath!, encoding: NSUTF8StringEncoding, error: nil)
//x = String(contentsOfFile: stopsPath!, encoding: NSUTF8StringEncoding, error: nil)
//x = String(contentsOfFile: stopsTimesPath!, encoding: NSUTF8StringEncoding, error: nil)
//x = String(contentsOfFile: routesPath!, encoding: NSUTF8StringEncoding, error: nil)
//        var data: NSData = routes!.dataUsingEncoding(NSUTF8StringEncoding)!
//        var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)!

//        if let j = json as? Array<AnyObject> {
//            if let d = j[0] as? NSDictionary {
//                var routeId = d["route_id"] as? Int
//                var routeShortName = d["route_short_name"] as? String
//                var routeType = d["route_type"] as? Int
//            }
//        }


public class RouteFetcher {
    
    public static func loadStops() -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()

        var bundle = NSBundle.mainBundle()
        var stopsPath = bundle.pathForResource(RouteFetcherConstants.StopsJsonPath, ofType: "json")
        
        var stops = String(contentsOfFile: stopsPath!, encoding: NSUTF8StringEncoding, error: nil)!
        var data: NSData = stops.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)!
        
        if let jsonArray = jsonObject as? Array<AnyObject> {
            for json in jsonArray {
                if let stopDictionary = json as? NSDictionary {
                    var retStop = Dictionary<String,AnyObject>()
                    
                    retStop[ RouteFetcherConstants.Stop.Identity ] = stopDictionary[ RouteFetcherConstants.Stop.Identity ] as? Int!
                    retStop[ RouteFetcherConstants.Stop.Code ] = stopDictionary[ RouteFetcherConstants.Stop.Code ] as? String!
                    retStop[ RouteFetcherConstants.Stop.Name ] = stopDictionary[ RouteFetcherConstants.Stop.Name ] as? String!
                    retStop[ RouteFetcherConstants.Stop.Lat ] = stopDictionary[ RouteFetcherConstants.Stop.Lat ] as? Double!
                    retStop[ RouteFetcherConstants.Stop.Lon ] = stopDictionary[ RouteFetcherConstants.Stop.Lon ] as? Double!
                    
                    ret.append(retStop)
                }
            }
        }
        
        return ret
    }

    public static func loadCalendarDates() -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
        var bundle = NSBundle.mainBundle()
        var calendarPath = bundle.pathForResource(RouteFetcherConstants.CalendarJsonPath, ofType: "json")
        
        var calendar = String(contentsOfFile: calendarPath!, encoding: NSUTF8StringEncoding, error: nil)!
        var data: NSData = calendar.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)!
        
        if let jsonArray = jsonObject as? Array<AnyObject> {
            for json in jsonArray {
                if let calendarDictionary = json as? NSDictionary {
                    var retCalendar = Dictionary<String,AnyObject>()
                    retCalendar[ RouteFetcherConstants.Calendar.ServiceId ] =
                        calendarDictionary[ RouteFetcherConstants.Calendar.ServiceId ] as? Int!
                    
                    retCalendar[ RouteFetcherConstants.Calendar.Date ] =
                        calendarDictionary[ RouteFetcherConstants.Calendar.Date ] as? String!
                    
                    retCalendar[ RouteFetcherConstants.Calendar.ExceptionType ] =
                        calendarDictionary[ RouteFetcherConstants.Calendar.ExceptionType ] as? String!
                    
                    ret.append(retCalendar)
                }
            }
        }
        
        return ret
    }

    public static func loadStopTimes() -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
        var bundle = NSBundle.mainBundle()
        var stopTimesPath = bundle.pathForResource(RouteFetcherConstants.StopTimesJsonPath, ofType: "json")
        
        var stopTimes = String(contentsOfFile: stopTimesPath!, encoding: NSUTF8StringEncoding, error: nil)!
        var data: NSData = stopTimes.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)!
        
        if let jsonArray = jsonObject as? Array<AnyObject> {
            for json in jsonArray {
                if let stopTimesDictionary = json as? NSDictionary {
                    var retStop = Dictionary<String,AnyObject>()
                    
                    retStop[ RouteFetcherConstants.StopTime.TripId ] =
                        stopTimesDictionary[ RouteFetcherConstants.StopTime.TripId ] as? Int!
                    
                    retStop[ RouteFetcherConstants.StopTime.ArrivalTime ] =
                        stopTimesDictionary[ RouteFetcherConstants.StopTime.ArrivalTime ] as? String!
                    
                    retStop[ RouteFetcherConstants.StopTime.DepartureTime ] =
                        stopTimesDictionary[ RouteFetcherConstants.StopTime.DepartureTime ] as? String!
                    
                    retStop[ RouteFetcherConstants.StopTime.StopId ] =
                        stopTimesDictionary[ RouteFetcherConstants.StopTime.StopId ] as? Int!
                    
                    retStop[ RouteFetcherConstants.StopTime.Sequence ] =
                        stopTimesDictionary[ RouteFetcherConstants.StopTime.Sequence ] as? Int!
                    
                    ret.append(retStop)
                }
            }
        }
        
        return ret
    }
    
    public static func loadTrips() -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
        var bundle = NSBundle.mainBundle()
        var tripsPath = bundle.pathForResource(RouteFetcherConstants.TripsJsonPath, ofType: "json")
        
        var trips = String(contentsOfFile: tripsPath!, encoding: NSUTF8StringEncoding, error: nil)!
        var data: NSData = trips.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)!
        
        if let jsonArray = jsonObject as? Array<AnyObject> {
            for json in jsonArray {
                if let tripDictionary = json as? NSDictionary {
                    var retStop = Dictionary<String,AnyObject>()
                    
                    retStop[ RouteFetcherConstants.Trip.Identity ] =
                        tripDictionary[ RouteFetcherConstants.Trip.Identity ] as? Int!
                    
                    retStop[ RouteFetcherConstants.Trip.ServiceId ] =
                        tripDictionary[ RouteFetcherConstants.Trip.ServiceId ] as? Int!
                    
                    retStop[ RouteFetcherConstants.Trip.RouteId ] =
                        tripDictionary[ RouteFetcherConstants.Trip.RouteId ] as? Int!
                    
                    retStop[ RouteFetcherConstants.Trip.Direction ] =
                        tripDictionary[ RouteFetcherConstants.Trip.Direction ] as? String!
                    
                    ret.append(retStop)
                }
            }
        }
        
        return ret
    }
 
    
}
