//
//  Locations.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/30/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Locations : NSObject, NSCoding {
    
    private struct PropertyKey {
        static let LocationsKey = "Locations"
    }

    
    private var locations = [Location]()
    
    public override init() {
        super.init()
    }
    
    private init( locations: [Location]) {
        self.locations = locations
    }
    
    public func numberOfLocations() -> Int {
        return locations.count
    }
    
    public func locationAtIndex( index : Int ) -> Location {
        return locations[index]
    }
    
    public func addStop( stop : RouteStop ) {
        for  location in locations  {
            if location.location == stop.Location {
                location.addStop(stop)
                return;
            }
        }
        
        var newLocation = Location(name: stop.Location )
        newLocation.addStop(stop)
        
        locations.append(newLocation)
        locations.sort { (before, after) -> Bool in
            before.location < after.location
        }
    }
    
    // MARK: Coding
    
    public func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(locations, forKey: PropertyKey.LocationsKey)
        aCoder.encodeInteger(self.locations.count, forKey: PropertyKey.LocationsKey)
        for index in 0 ..< self.locations.count {
            aCoder.encodeObject( self.locations[ index ] )
        }

    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        //let locations = aDecoder.decodeObjectForKey(PropertyKey.LocationsKey) as? [Location]
        let locationsCount = aDecoder.decodeIntegerForKey(PropertyKey.LocationsKey)
        var locations = [Location]()
        for index in 0 ..< locationsCount {
            if var location = aDecoder.decodeObject() as? Location {
                locations.append(location)
            }
        }
      
        self.init( locations: locations)
    }

    
}
