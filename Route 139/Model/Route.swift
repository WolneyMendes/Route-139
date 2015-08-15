//
//  Route.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/15/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class Route {
    public let Name       : String
    public let Identity   : Int
    
    init(name: String, identity :Int) {
        Name = name
        Identity = identity
    }

    public static func FromRouteFetcher() -> Array<Route>  {
        
        let routes = RouteFetcher.loadRoute()
        
        var ret = routes.map( {
            (let route ) -> Route in
            let name = route[RouteFetcherConstants.Route.Name] as! String
            let identity = route[RouteFetcherConstants.Route.Identity] as! Int
            return Route(name:name, identity:identity)
            }
        )
        
        return ret;
        
    }

}