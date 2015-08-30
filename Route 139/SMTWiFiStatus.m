//
//  SMTWiFiStatus.m
//  Route139Test1
//
//  Created by Wolney Mendes on 8/28/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import "SMTWiFiStatus.h"

@implementation SMTWiFiStatus

- (BOOL) isWiFiEnabled {
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs * interfaces;
    
    if( ! getifaddrs( &interfaces ) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

-(NSDictionary*) wifiDetails {
    
    CFArrayRef si = CNCopySupportedInterfaces();
    
    if ( si == 0 )
        return nil;
    
    return
    
    ( __bridge NSDictionary *)
    CNCopyCurrentNetworkInfo(
            CFArrayGetValueAtIndex(si, 0));
}

-(BOOL) isWiFiConnected {
    return [self wifiDetails] == nil ? NO : YES;
}

-(NSString*) BSSID {
    return [self wifiDetails][@"BSSID"];
}

-(NSString*) SSID {
    return [self wifiDetails][@"SSID"];
}

@end
