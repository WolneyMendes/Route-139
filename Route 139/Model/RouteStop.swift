//
//  RouteStop.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class RouteStop {
    
    public let Name       : String
    public let Identity   : Int
    public let Code       : String
    public let Latitude   : Double
    public let Longitude  : Double
    public let Location   : String
    
    init(name: String, identity :Int, code: String, latitude: Double, longitude: Double, location:String) {
        Name = name
        Identity = identity
        Code = code
        Latitude = latitude
        Longitude = longitude
        Location = location
    }
    
    
    public static func FromRouteFetcher() -> Array<RouteStop>  {
    
        let stops = RouteFetcher.loadStops()
        
        var ret = stops.map( {
            (let stop ) -> RouteStop in
            let name = stop[RouteFetcherConstants.Stop.Name] as! String
            let identity = stop[RouteFetcherConstants.Stop.Identity] as! Int
            let code = stop[RouteFetcherConstants.Stop.Code] as! String
            let latitude = stop[RouteFetcherConstants.Stop.Lat] as! Double
            let longitude = stop[RouteFetcherConstants.Stop.Lon] as! Double
            let location = stop[RouteFetcherConstants.Stop.Location] as! String
            return RouteStop(name:name, identity:identity, code: code, latitude: latitude, longitude: longitude, location: location)
            }
        )
        
        return ret;
    
    }
    
    public func Equals( other : RouteStop ) -> Bool {
        return
            Name == other.Name &&
                Identity == other.Identity &&
                Code == other.Code &&
                Latitude == other.Latitude &&
                Longitude == other.Longitude
    }

    
}