//
//  Route.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/15/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Route : NSObject, NSCoding {
    
    private struct PropertyKey {
        static let NameKey = "Name"
        static let IdentityKey = "Identity"
    }

    
    public let Name       : String
    public let Identity   : Int
    
    init(name: String, identity :Int) {
        Name = name
        Identity = identity
        
        super.init()
    }

    public static func FromRouteFetcher() -> Array<Route> {
        return FromRouteFetchedArray(RouteFetcher.loadRoute())
    }
    
    
    public static func FromRouteFetchedArray( routes : Array<Dictionary<String,AnyObject>> ) -> Array<Route>  {
        var ret = routes.map( {
            (let route ) -> Route in
            let name = route[RouteFetcherConstants.Route.Name] as! String
            let identity = route[RouteFetcherConstants.Route.Identity] as! Int
            return Route(name:name, identity:identity)
            }
        )
        
        return ret;
        
    }
    
    // MARK: Coding
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(Name, forKey: PropertyKey.NameKey)
        aCoder.encodeInteger(Identity, forKey: PropertyKey.IdentityKey)
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObjectForKey(PropertyKey.NameKey) as? String
        let identity = aDecoder.decodeIntegerForKey(PropertyKey.IdentityKey)
        
        self.init( name: name!, identity: identity)
    }


}