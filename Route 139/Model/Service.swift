//
//  Service.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/14/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Service : NSObject, NSCoding {
    
    private struct PropertyKey {
        static let IdentityKey = "Identity"
        static let InboundKey = "Inbound"
        static let OutboundKey = "Outbound"
    }

    
    private var _inboundTrips = Array<RouteTrip>()
    private var _outboundTrips = Array<RouteTrip>()
    
    public let Identity : Int
    
    public var inboundTrips : Array<RouteTrip>{ get { return _inboundTrips } }
    public var outboundTrips : Array<RouteTrip>{ get { return _outboundTrips } }
    
    init( identity: Int ) {
        Identity = identity
        
        super.init()
    }
    
    private init( identity:Int, inbound: Array<RouteTrip>, outbound: Array<RouteTrip> ) {
        Identity = identity
        _inboundTrips = inbound
        _outboundTrips = outbound
        
        super.init()
    }
    
    public func addTrip( trip: RouteTrip ) {
        if trip.Inboud {
            _inboundTrips.append(trip)
        } else {
            _outboundTrips.append(trip)
        }
    }
    
    // MARK: Coding
    
    public func encodeWithCoder(aCoder: NSCoder) {

        aCoder.encodeInteger(Identity, forKey: PropertyKey.IdentityKey)
        
        //aCoder.encodeObject(_inboundTrips, forKey: PropertyKey.InboundKey)
        aCoder.encodeInteger(self._inboundTrips.count, forKey: PropertyKey.InboundKey)
        for index in 0 ..< self._inboundTrips.count {
            aCoder.encodeObject( self._inboundTrips[ index ] )
        }

        //aCoder.encodeObject(_outboundTrips, forKey: PropertyKey.OutboundKey)
        aCoder.encodeInteger(self._outboundTrips.count, forKey: PropertyKey.OutboundKey)
        for index in 0 ..< self._outboundTrips.count {
            aCoder.encodeObject( self._outboundTrips[ index ] )
        }


    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        let identity = aDecoder.decodeIntegerForKey(PropertyKey.IdentityKey)
        
        //let inbound = aDecoder.decodeObjectForKey(PropertyKey.InboundKey) as? Array<RouteTrip>
        let inboundCount = aDecoder.decodeIntegerForKey(PropertyKey.InboundKey)
        var inbound = [RouteTrip]()
        for index in 0 ..< inboundCount {
            if var routeTrip = aDecoder.decodeObject() as? RouteTrip {
                inbound.append(routeTrip)
            }
        }

        
        //let outbound = aDecoder.decodeObjectForKey(PropertyKey.OutboundKey) as? Array<RouteTrip>
        let outboundCount = aDecoder.decodeIntegerForKey(PropertyKey.OutboundKey)
        var outbound = [RouteTrip]()
        for index in 0 ..< outboundCount {
            if var routeTrip = aDecoder.decodeObject() as? RouteTrip {
                outbound.append(routeTrip)
            }
        }
        
        self.init( identity:identity, inbound: inbound, outbound: outbound)
    }

}