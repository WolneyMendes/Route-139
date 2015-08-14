//
//  Locations.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/30/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Locations {
    
    private var locations = [Location]()
    
    public func numberOfLocations() -> Int {
        return locations.count
    }
    
    public func locationAtIndex( index : Int ) -> Location {
        return locations[index]
    }
    
    public func addStop( stop : RouteStop ) {
        for  location in locations  {
//            if location.location == stop.Location {
                location.addStop(stop)
                return;
//            }
        }
        
        var newLocation = Location(name: "" /*stop.Location*/ )
        newLocation.addStop(stop)
        
        locations.append(newLocation)
    }
    
}
