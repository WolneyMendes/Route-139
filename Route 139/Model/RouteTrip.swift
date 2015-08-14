//
//  RouteTrip.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/12/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//
//


import Foundation

public class RouteTrip {

    public let RouteId : Int
    public let ServiceId : Int
    public let Identity : Int
    public let Inboud : Bool
    
    init( routeId: Int, serviceId: Int, identity: Int, inboud: Bool ) {
        RouteId = routeId
        ServiceId = serviceId
        Identity = identity
        Inboud = inboud
    }
    
    public static func FromRouteFetcher( trips : Array<Dictionary<String,AnyObject>> ) -> Array<RouteTrip>  {
        
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

}