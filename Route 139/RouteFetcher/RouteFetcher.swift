//
//  RouteFetcher.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class RouteFetcher {
    
    public static func getTimeStamps( jsonObject: AnyObject ) -> Dictionary<String,Int> {
        
        var ret = Dictionary<String,Int>()
        
        if let stopDictionary = jsonObject as? NSDictionary {
            ret[ RouteFetcherConstants.Timestamp.Calendar] = (stopDictionary[ RouteFetcherConstants.Timestamp.Calendar ] as! Int)
            ret[ RouteFetcherConstants.Timestamp.Routes] = (stopDictionary[ RouteFetcherConstants.Timestamp.Routes ] as! Int)
            ret[ RouteFetcherConstants.Timestamp.Stops] = (stopDictionary[ RouteFetcherConstants.Timestamp.Stops ] as! Int)
            ret[ RouteFetcherConstants.Timestamp.StopTimes] = (stopDictionary[ RouteFetcherConstants.Timestamp.StopTimes ] as! Int)
            ret[ RouteFetcherConstants.Timestamp.Terminal] = (stopDictionary[ RouteFetcherConstants.Timestamp.Terminal ] as! Int)
            ret[ RouteFetcherConstants.Timestamp.Calendar] = (stopDictionary[ RouteFetcherConstants.Timestamp.Calendar ] as! Int)
        }
        
        return ret
    }
    
    public static func getTerminal( jsonObject: AnyObject) -> Dictionary<String,Int> {
        var ret = Dictionary<String,Int>()
        
        if let terminalDictionary = jsonObject as? NSDictionary {
            ret[ RouteFetcherConstants.Terminal.Inbound ] = (terminalDictionary[ RouteFetcherConstants.Terminal.Inbound ] as! Int)
            ret[ RouteFetcherConstants.Terminal.OutBound ] = (terminalDictionary[ RouteFetcherConstants.Terminal.OutBound] as! Int)
        }
        
        return ret;
    }
    
    public static func loadRoute() -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
        var bundle = NSBundle.mainBundle()
        var routePath = bundle.pathForResource(RouteFetcherConstants.RoutesJsonPath, ofType: "json")
        
        var routes = String(contentsOfFile: routePath!, encoding: NSUTF8StringEncoding, error: nil)!
        var data: NSData = routes.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)!
        
        return jsonToRoute(jsonObject);
    }

    public static func jsonToRoute(jsonObject: AnyObject) -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
        if let jsonArray = jsonObject as? Array<AnyObject> {
            for json in jsonArray {
                if let stopDictionary = json as? NSDictionary {
                    var retStop = Dictionary<String,AnyObject>()
                    
                    retStop[ RouteFetcherConstants.Route.Identity ] = stopDictionary[ RouteFetcherConstants.Route.Identity ] as? Int!
                    retStop[ RouteFetcherConstants.Route.Name ] = "\((stopDictionary[ RouteFetcherConstants.Route.Name ] as? Int!)!)"
                    
                    ret.append(retStop)
                }
            }
        }
        
        return ret
    }
    
    public static func loadStops() -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()

        var bundle = NSBundle.mainBundle()
        var stopsPath = bundle.pathForResource(RouteFetcherConstants.StopsJsonPath, ofType: "json")
        
        var stops = String(contentsOfFile: stopsPath!, encoding: NSUTF8StringEncoding, error: nil)!
        var data: NSData = stops.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)!
        
        return jsonToStops(jsonObject);
    }

    public static func jsonToStops(jsonObject: AnyObject) -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
        if let jsonArray = jsonObject as? Array<AnyObject> {
            for json in jsonArray {
                if let stopDictionary = json as? NSDictionary {
                    var retStop = Dictionary<String,AnyObject>()
                    
                    retStop[ RouteFetcherConstants.Stop.Identity ] = stopDictionary[ RouteFetcherConstants.Stop.Identity ] as? Int!
                    retStop[ RouteFetcherConstants.Stop.Code ]     = "\((stopDictionary[ RouteFetcherConstants.Stop.Code ] as? Int!)!)"
                    retStop[ RouteFetcherConstants.Stop.Name ]     = stopDictionary[ RouteFetcherConstants.Stop.Name ] as? String!
                    retStop[ RouteFetcherConstants.Stop.Lat ]      = stopDictionary[ RouteFetcherConstants.Stop.Lat ] as? Double!
                    retStop[ RouteFetcherConstants.Stop.Lon ]      = stopDictionary[ RouteFetcherConstants.Stop.Lon ] as? Double!
                    retStop[ RouteFetcherConstants.Stop.Location]  = stopDictionary[ RouteFetcherConstants.Stop.Location ] as? String!
                    
                    ret.append(retStop)
                }
            }
        }
        
        return ret
    }
    
    public static func loadCalendarDates() -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        var error : NSError? = NSError()
        
        var bundle = NSBundle.mainBundle()
        var calendarPath = bundle.pathForResource(RouteFetcherConstants.CalendarJsonPath, ofType: "json")
        
        var calendar = String(contentsOfFile: calendarPath!, encoding: NSUTF8StringEncoding, error: nil)!
        var data: NSData = calendar.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)!
        
        return jsonToCalendarDates(jsonObject)
    }

    public static func jsonToCalendarDates(jsonObject: AnyObject) -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
        if let jsonArray = jsonObject as? Array<AnyObject> {
            for json in jsonArray {
                if let calendarDictionary = json as? NSDictionary {
                    var retCalendar = Dictionary<String,AnyObject>()
                    retCalendar[ RouteFetcherConstants.Calendar.ServiceId ] =
                        calendarDictionary[ RouteFetcherConstants.Calendar.ServiceId ] as? Int!
                    
                    retCalendar[ RouteFetcherConstants.Calendar.Date ] =
                    "\((calendarDictionary[ RouteFetcherConstants.Calendar.Date ] as? Int!)!)"
                    
                    retCalendar[ RouteFetcherConstants.Calendar.ExceptionType ] =
                    "\((calendarDictionary[ RouteFetcherConstants.Calendar.ExceptionType ] as? Int!)!)"
                    
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
        
        return jsonToStopTimes(jsonObject)
    }
    
    public static func jsonToStopTimes(jsonObject: AnyObject) -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
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
        
        return jsonToTrips(jsonObject)
    }
 
    public static func jsonToTrips(jsonObject: AnyObject) -> Array<Dictionary<String,AnyObject>> {
        
        var ret = Array<Dictionary<String,AnyObject>>()
        
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
                    "\((tripDictionary[ RouteFetcherConstants.Trip.Direction ] as? Int!)!)"
                    
                    ret.append(retStop)
                }
            }
        }
        
        return ret
    }
    
    
}
