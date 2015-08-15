//
//  Service.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/14/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Service {
    
    private var _inboundTrips = Array<RouteTrip>()
    private var _outboundTrips = Array<RouteTrip>()
    
    public let Identity : Int
    
    public var inboundTrips : Array<RouteTrip>{ get { return _inboundTrips } }
    public var outboundTrips : Array<RouteTrip>{ get { return _outboundTrips } }
    
    init( identity: Int ) {
        Identity = identity
    }
    
    public func addTrip( trip: RouteTrip ) {
        if trip.Inboud {
            _inboundTrips.append(trip)
        } else {
            _outboundTrips.append(trip)
        }
    }
}