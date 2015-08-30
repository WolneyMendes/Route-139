//
//  AppDelegate.swift
//  Route 139
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var observing = false
    
    static var configurationManager : ConfigurationManager?
    static var modelStore : ModelStore?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        startObserving()
        
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.StopSelectionChangeNotification, object: nil)

        var wstatus = SMTWiFiStatus();
        
        var enabled = wstatus.isWiFiEnabled()
        var connected = wstatus.isWiFiConnected()
        var BSSID = wstatus.BSSID()
        var SSID = wstatus.SSID()
        
        var rc = RestCall()
        //rc.executeGet("http://" + AppDelegate.Constants.ServerName + "/timestampx?y=1", callBack: TestRestCallBack())
        rc.executeGet("http://" + AppDelegate.Constants.ServerName + "/timestamp", callBack: TimestampCallBack())

        //rc.executePost("http://" + AppDelegate.Constants.ServerName + "/timestamp", stringPost: "x=2&y=3", callBack: TestRestCallBack() )
        
        //var err : NSError
        //var params = Dictionary<String,String>()
        //params["Var1"] = "Par1"
        //params["Var2"] = "Par2"
        //var obj: AnyObject = params as AnyObject
        //var data = NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.allZeros, error: nil)!
        //rc.executePost("http://" + AppDelegate.Constants.ServerName + "/timestamp", json: data, callBack: TestRestCallBack() )
        
        let configManager = ConfigurationManager()
        configManager.load()
        
        AppDelegate.configurationManager = configManager
        AppDelegate.modelStore = ModelStore(configManager: configManager)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        stopObserving()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        startObserving()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        stopObserving()
    }

    internal struct Constants {
        static let RouteConfigurationChange = "com.wfm.RouteConfigurationChange"
        static let OutBoundPortAuthorityStop = 3511
        static let InBoundPortAuthorityStop = 43274
        static let ServerName = "104.236.119.0:8000"
        
        static let NetworkErrorCodeDomain = "com.wfm.webresult"
        static let ServerSideErrorCodeDomain = "com.wfm.server"
        
        struct Application {
            struct  ErrorCode {
            
            static let Domain = "com.wfm"
            
                struct Values {
                    static let ReceivedInvalidJSON = 100
                }
            }
        }
    }
    
    func updateNotificationSent() {
        NSLog("Got notification")
        
        AppDelegate.configurationManager?.save()
        AppDelegate.modelStore?.loadFromConfig()
    }
    
    func startObserving() {
        NSLog("Observing")
        if !observing {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationSent", name: Constants.RouteConfigurationChange, object: nil)
            observing = true
        }
    }
    
    func stopObserving() {
        NSLog("Not Observing")
        if observing {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.RouteConfigurationChange, object: nil)
            observing = false
        }
    }
    
}

