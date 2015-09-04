//
//  RouteStop.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class RouteStop : NSObject, NSCoding {

    private struct PropertyKey {
        static let NameKey       = "Name"
        static let IdentityKey   = "Identity"
        static let CodeKey       = "Code"
        static let LatitudeKey   = "Latitude"
        static let LongitudeKey  = "Longitude"
        static let LocationKey   = "Location"
    }

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
        
        super.init()
    }
    
    public static func FromRouteFetcher() -> Array<RouteStop>  {
        return FromRouteFetchedArray( RouteFetcher.loadStops() )
    }
    
    public static func FromRouteFetchedArray( stops: Array<Dictionary<String,AnyObject>>) -> Array<RouteStop>  {
    
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

    // MARK: Coding
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.Name, forKey: PropertyKey.NameKey)
        aCoder.encodeInteger(self.Identity, forKey: PropertyKey.IdentityKey)
        aCoder.encodeObject(self.Code, forKey: PropertyKey.CodeKey)
        aCoder.encodeDouble(self.Latitude, forKey: PropertyKey.LatitudeKey)
        aCoder.encodeDouble(self.Longitude, forKey: PropertyKey.LongitudeKey)
        aCoder.encodeObject(self.Location, forKey: PropertyKey.LocationKey)

    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        let Name      = aDecoder.decodeObjectForKey(PropertyKey.NameKey) as? String
        let Identity  = aDecoder.decodeIntegerForKey(PropertyKey.IdentityKey)
        let Code      = aDecoder.decodeObjectForKey(PropertyKey.CodeKey) as? String
        let Latitude  = aDecoder.decodeDoubleForKey(PropertyKey.LatitudeKey)
        let Longitude = aDecoder.decodeDoubleForKey(PropertyKey.LongitudeKey)
        let Location  = aDecoder.decodeObjectForKey(PropertyKey.LocationKey) as? String

        self.init(name: Name!, identity :Identity, code: Code!, latitude: Latitude, longitude: Longitude, location:Location!)
    }

    
}