//
//  Location.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/30/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Location {
    
    let location : String
    private var stops : [RouteStop]
    
    var numberOfStops : Int {
        return stops.count
    }
    
    init( name: String ) {
        location = name
        stops = []
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
    }
    
}
