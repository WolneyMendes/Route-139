//
//  ServiceArray.swift
//  Route 139
//
//  Created by Wolney Mendes on 9/1/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class ServiceArray : NSObject, NSCoding, SequenceType {
    
    private struct PropertyKey {
        static let ArrayKey = "Array"
    }

    private var services = [Service]()
    
    public override init() {
        super.init()
    }
    
    private init(services: [Service]) {
        self.services = services
    }
    
    public func append( service: Service ) {
        services.append(service)
    }
    
    // MARK: SequenceType
    
    public func generate() -> ServiceArrayGenerator {
        return ServiceArrayGenerator(array: self)
    }
    
    public struct ServiceArrayGenerator : GeneratorType {
        
        var array: ServiceArray
        var index = 0
        
        init(array: ServiceArray) {
            self.array = array
        }
        
        mutating public func next() -> Service? {
            return index < array.services.count ? array.services[index++] : nil
        }
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        
        // MARK: NSCoding
        aCoder.encodeInteger(self.services.count, forKey: PropertyKey.ArrayKey)
        for index in 0 ..< self.services.count {
            aCoder.encodeObject( self.services[ index ] )
        }
    }
    
    
    required convenience public init(coder aDecoder: NSCoder) {
        
        //let inbound = aDecoder.decodeObjectForKey(PropertyKey.InboundKey) as? Array<RouteTrip>
        let count = aDecoder.decodeIntegerForKey(PropertyKey.ArrayKey)
        var services = [Service]()
        for index in 0 ..< count {
            if var service = aDecoder.decodeObject() as? Service {
                services.append(service)
            }
        }
        
        self.init(services: services)
    }

    
}

 