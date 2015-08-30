//
//  SMTWiFiStatus.h
//  Route139Test1
//
//  Created by Wolney Mendes on 8/28/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

#ifndef Route139Test1_SMTWiFiStatus_h
#define Route139Test1_SMTWiFiStatus_h

#import <Foundation/Foundation.h>

@interface SMTWiFiStatus : NSObject

- (BOOL) isWiFiEnabled;
- (BOOL) isWiFiConnected;
- (NSString* ) BSSID;
- (NSString* ) SSID;

@end

#endif
