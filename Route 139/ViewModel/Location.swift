//
//  Location.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/30/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Location : NSObject, NSCoding {
  
    private struct PropertyKey {
        static let LocationKey = "Location"
        static let StopsKey = "Stops"
    }

    
    let location : String
    private var stops : [RouteStop]
    
    var numberOfStops : Int {
        return stops.count
    }
    
    init( name: String ) {
        location = name
        stops = []
        
        super.init()
    }
    
    private init( name: String, stops: [RouteStop] ) {
        location = name;
        self.stops = stops
        
        super.init()
    }
    
    public func stopAt( index : Int ) -> RouteStop? {
        if( index > stops.count ) {
            return nil
        }
        return stops[index]
    }
    
    public func addStop( newStop: RouteStop ) {
        for stop in stops {
            if newStop.Equals(stop) {
                return;
            }
        }
        stops.append(newStop);
        stops.sort { (before, after) -> Bool in
            before.Name < after.Name
        }
    }
   
    // MARK: Coding
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location, forKey: PropertyKey.LocationKey)
        
        //aCoder.encodeObject(stops, forKey: PropertyKey.StopsKey)
        aCoder.encodeInteger(self.stops.count, forKey: PropertyKey.StopsKey)
        for index in 0 ..< self.stops.count {
            aCoder.encodeObject( self.stops[ index ] )
        }

    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        let location = aDecoder.decodeObjectForKey(PropertyKey.LocationKey) as? String
        
        //let stops = aDecoder.decodeObjectForKey(PropertyKey.StopsKey) as? [RouteStop]
        let stopsCount = aDecoder.decodeIntegerForKey(PropertyKey.StopsKey)
        var stops = [RouteStop]()
        for index in 0 ..< stopsCount {
            if var stop = aDecoder.decodeObject() as? RouteStop {
                stops.append(stop)
            }
        }

        self.init( name: location!, stops: stops)
    }

}
