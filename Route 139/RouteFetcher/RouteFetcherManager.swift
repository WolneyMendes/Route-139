//
//  RouterFetcherManager.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/30/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

internal protocol StateProtocol {
    func configurationChanged() -> StateProtocol;
    func newTimeStamp() -> StateProtocol;
    func wifiStateChanged() -> StateProtocol;
    func allowToDownload() -> StateProtocol
    func allDownloadsAreCompleted() -> StateProtocol;
    func processingIsDone() -> StateProtocol;
}

internal protocol StateManagerProtocol {
    var canAutomaticallyDownload : Bool {get}
    var canAutomaticallyDownloadViaCelullar : Bool {get}
    var isWifiConnected : Bool {get}
    
    func startAllDownloads();
    func stopAllDownloads();
    func waitingForPermissionToDownload();
    func startProcessing();
    func stopProcessing();
}

public class RouteFetcherManager : StateManagerProtocol {
    
    private let configManager : ConfigurationManager
    public  var canAutomaticallyDownload: Bool = true
    public  var canAutomaticallyDownloadViaCelullar: Bool = false
    private var timestamp: Int = 0
    private var timestampToBeDownload: Int?
    public  var isWifiConnected = false
    
    private var currentState : StateProtocol?
    
    private var checkTimestampTimer : NSTimer? = nil
    private var pollTimer : NSTimer? = nil
    
    private var timeStampCallBack : TimestampCallback?
    private var terminalCallBack : TerminalCallback?
    private var routesCallBack : RoutesCallback?
    private var stopTimesCallBack : StopTimesCallback?
    private var tripsCallBack : TripsCallback?
    private var calendarCallBack : CalendarDateCallback?
    private var stopsCallBack : StopsCallback?
    
    // NOTE: There must be a better way then that!!
    private var timeStampTask : NSURLSessionDataTask?
    private var terminalTask : NSURLSessionDataTask?
    private var routeTask : NSURLSessionDataTask?
    private var stopTimesTask : NSURLSessionDataTask?
    private var tripsTask : NSURLSessionDataTask?
    private var calendarTask : NSURLSessionDataTask?
    private var stopsTask : NSURLSessionDataTask?
    
    
    private let restCall = RestCall(timeoutInMSeconds: 25000.0)
    
    public init( configManager: ConfigurationManager ) {
        
        self.configManager = configManager
        
        if let modelBuilder = configManager.modelBuilder {
            self.timestamp = modelBuilder.timestamp
        }
        
        currentState = IdleState(stateManager: self)
        loadFromConfig()

        timeStampCallBack = TimestampCallback(callBack: self.OnGetTimeStamp );
        terminalCallBack = TerminalCallback(callBack: self.OnGetTerminal);
        routesCallBack = RoutesCallback(callBack: self.OnGetRoutes );
        stopTimesCallBack = StopTimesCallback(callBack: self.OnGetStopTimes);
        tripsCallBack = TripsCallback(callBack: self.OnGetTrips);
        calendarCallBack = CalendarDateCallback(callBack: self.OnGetCalendar);
        stopsCallBack = StopsCallback(callBack: self.OnGetStops);

        checkTimestampTimer = NSTimer.scheduledTimerWithTimeInterval(30*60, target: self, selector: "checkTimeStamp:", userInfo: nil, repeats: true)
        checkTimestampTimer?.tolerance = 10

        checkTimestampTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "clockTick:", userInfo: nil, repeats: true)
        checkTimestampTimer?.tolerance = 3

        clockTick() // To update Wifi state
        checkTimeStamp()
        

        //var queueToDispatch = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        //var main_queue = dispatch_get_main_queue()
        //
        //    dispatch_async(queueToDispatch) {
        //
        //        dispatch_async(main_queue) {
        //
        //        }
        //
        //}
        
        //let delayInSeconds = 25.0
        //let delay = Int64(delayInSeconds*Double(NSEC_PER_MSEC))
        //let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay)
        //dispatch_after(dispatchTime, main_queue) {
        //
        //}
        
    }
    
    public func loadFromConfig() {
        self.canAutomaticallyDownload = configManager.canDownloadAutomatically
        self.canAutomaticallyDownloadViaCelullar = configManager.canDownloadAutomaticallyViaCellular
        
        currentState = currentState!.configurationChanged()
    }
    
    // MARK: Download Events
    
    private func OnGetTimeStamp() {
        timeStampTask = nil
        if let error = self.timeStampCallBack!.error {
            println( "Got a error while getting timestamp information" );
            println( error );
        } else {
            if let ts = self.timeStampCallBack!.timeStamp {
                if ts != timestamp && self.timeStampCallBack!.timeStamp != timestampToBeDownload {
                    currentState = currentState!.newTimeStamp()
                } else {
                    println("New new information")
                }
            }
        }
    }
    
    private func OnGetTerminal() {
        println( "OnGetTerminal" )
        terminalTask = nil
        checkIfAllDownloadsAreDone()
    }

    private func OnGetRoutes() {
        println( "OnGetRoutes" )
        routeTask = nil
        checkIfAllDownloadsAreDone()
    }
    
    private func OnGetStopTimes() {
        println( "OnGetStopTimes" )
        stopTimesTask = nil
        checkIfAllDownloadsAreDone()
    }
    
    private func OnGetTrips() {
        println("OnGetTrips")
        tripsTask = nil
        checkIfAllDownloadsAreDone()
    }
    
    private func OnGetCalendar() {
        println("OnGetCalendar")
        calendarTask = nil
        checkIfAllDownloadsAreDone()
    }
    
    private func OnGetStops() {
        println("OnGetStops")
        stopsTask = nil
        checkIfAllDownloadsAreDone()
    }
    
    private func checkIfAllDownloadsAreDone() {
        
        if  timeStampTask == nil &&
            terminalTask  == nil &&
            routeTask     == nil &&
            stopTimesTask == nil &&
            tripsTask     == nil &&
            calendarTask  == nil &&
            stopsTask     == nil {
                currentState = currentState?.allDownloadsAreCompleted()
        }
    }
    
    // MARK: Timer Methods
    
    @objc private func checkTimeStamp(timer:NSTimer) {
        checkTimeStamp()
    }
    private func checkTimeStamp() {
        println("CheckTimeStamp")
        timeStampTask = restCall.executeGet("http://" + AppDelegate.Constants.ServerName + "/timestamp", callBack: timeStampCallBack!)
        timestampToBeDownload = timestamp
    }
    
    @objc private func clockTick(timer:NSTimer) {
        println("Tick")
        clockTick()
    }
    private func clockTick() {
        var currentWifiState = getWifiConnectedState()
        
        // Wifi Changed state
        if currentWifiState != isWifiConnected {
            isWifiConnected = currentWifiState
            currentState = currentState!.wifiStateChanged()
        }
    }
    
    private func getWifiConnectedState() -> Bool {
        var wstatus = SMTWiFiStatus();
        
        var enabled = wstatus.isWiFiEnabled()
        var connected = wstatus.isWiFiConnected()
        //var BSSID = wstatus.BSSID()
        //var SSID = wstatus.SSID()
        
        return enabled && connected
    }
    
    // MARK: StateManager Protocol
    func startAllDownloads() {
        println("StartAllDownloads")
        terminalTask  = restCall.executeGet("http://" + AppDelegate.Constants.ServerName + "/routes", callBack: routesCallBack!)
        routeTask     = restCall.executeGet("http://" + AppDelegate.Constants.ServerName + "/terminal", callBack: terminalCallBack!)
        stopTimesTask = restCall.executeGet("http://" + AppDelegate.Constants.ServerName + "/stop_times", callBack: stopTimesCallBack!)
        tripsTask     = restCall.executeGet("http://" + AppDelegate.Constants.ServerName + "/trips", callBack: tripsCallBack!)
        calendarTask  = restCall.executeGet("http://" + AppDelegate.Constants.ServerName + "/calendar_dates", callBack: calendarCallBack!)
        stopsTask     = restCall.executeGet("http://" + AppDelegate.Constants.ServerName + "/stops", callBack: stopsCallBack!)
    }
    
    func stopAllDownloads() {
        println("stopAllDownloads")
        timeStampTask?.cancel()
        routeTask?.cancel()
        stopTimesTask?.cancel()
        tripsTask?.cancel()
        calendarTask?.cancel()
        stopsTask?.cancel()
    }
    
    func waitingForPermissionToDownload() {
        println("waitingForPermissionToDownload")
    }

    func startProcessing() {
        println("startProcessing")
        
        var mb = ModelBuilder(
            timestamp: timeStampCallBack!.timeStamp!,
            terminals: terminalCallBack!.terminals!,
            allCalendar: calendarCallBack!.allCalendar!,
            allRoutes: routesCallBack!.allRoutes!,
            allStops: stopsCallBack!.allStops!,
            allStopTime: stopTimesCallBack!.allStopTime!,
            allTrips: tripsCallBack!.allTrips!)
        
        mb.startAsync { () -> Void in
            println("Build is done")
            self.currentState = self.currentState?.processingIsDone()
            AppDelegate.configurationManager?.modelBuilder = mb
            self.timestamp = mb.timestamp
        }

    }
    
    func stopProcessing() {
        println("stopProcessing")
    }

    
    // MARK: States
    
    // No Download is under way
    private class IdleState : StateProtocol {

        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building IdleState");
            self.stateManager = stateManager
        }

        func configurationChanged() -> StateProtocol {
            println("IdleState.configurationChanges");
            return self;
        }
        func newTimeStamp() -> StateProtocol {
            println("IdleState.newTimeStamp");
            if stateManager.isWifiConnected {
                if stateManager.canAutomaticallyDownload {
                    // It is connected to Wifi and it should start automatically
                    stateManager.startAllDownloads()
                    return DownloadWhileOnWifi(stateManager: stateManager)
                } else {
                    // it is connected to Wifi but need for permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverWifi(stateManager: stateManager)
                }
            } else {
                if stateManager.canAutomaticallyDownload && stateManager.canAutomaticallyDownloadViaCelullar {
                    // is is not connected to Wifi but it can start automatically over cellular
                    stateManager.startAllDownloads()
                    return DownloadWhileNotOnWifi(stateManager: stateManager)
                } else {
                    // it is not connected to Wifi and has to have permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager)
                }
            }
        }
        func wifiStateChanged() -> StateProtocol {
            println("IdleState.wifiStateChanged");
            return self;
        }
        
        func allowToDownload() -> StateProtocol {
            println("IdleState.allowToDownload");
            return self;
        }
        func allDownloadsAreCompleted() -> StateProtocol {
            println("IdleState.alloDownloadsAreCompleted")
            return self;
        }
        func processingIsDone() -> StateProtocol {
            println("IdleState.processingIsDone")
            return self;
        }

    }
    
    // Downloading all files under the way over Wifi.
    private class DownloadWhileOnWifi : StateProtocol {
        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building DownloadWhileOnWifi");
            self.stateManager = stateManager
        }
        
        func configurationChanged() -> StateProtocol {
            println("DownloadWhileOnWifi.configurationChanged");
            if !stateManager.canAutomaticallyDownload {
                stateManager.stopAllDownloads()
                return AwaitingPermissionToDownloadOverWifi(stateManager: stateManager)
            }
            return self;
        }
        func newTimeStamp() -> StateProtocol {
            println("DownloadWhileOnWifi.newTimeStamp")
            stateManager.stopAllDownloads()
            if stateManager.isWifiConnected {
                if stateManager.canAutomaticallyDownload {
                    // It is connected to Wifi and it should start automatically
                    stateManager.startAllDownloads()
                    return self
                } else {
                    // it is connected to Wifi but need for permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverWifi(stateManager: stateManager)
                }
            } else {
                if stateManager.canAutomaticallyDownload && stateManager.canAutomaticallyDownloadViaCelullar {
                    // is is not connected to Wifi but it can start automatically over cellular
                    stateManager.startAllDownloads()
                    return DownloadWhileNotOnWifi(stateManager: stateManager)
                } else {
                    // it is not connected to Wifi and has to have permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager)
                }
            }
        }
        func wifiStateChanged() -> StateProtocol {
            println("DownloadWhileOnWifi.wifiStateChanged");
            if !stateManager.isWifiConnected {
                stateManager.stopAllDownloads()
                if stateManager.canAutomaticallyDownload && stateManager.canAutomaticallyDownloadViaCelullar {
                    // is is not connected to Wifi but it can start automatically over cellular
                    stateManager.startAllDownloads()
                    return DownloadWhileNotOnWifi(stateManager: stateManager)
                } else {
                    // it is not connected to Wifi and has to have permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager)
                }
            }
            return self;
        }
        
        func allowToDownload( ) -> StateProtocol {
            println("DownloadWhileOnWifi.allowToDownload");
            return self;
        }
        
        func allDownloadsAreCompleted() -> StateProtocol {
            println("DownloadWhileOnWifi.allDownloadsAreCompleted");
            stateManager.startProcessing()
            return WaitingForProcessing(stateManager: stateManager);
        }
        func processingIsDone() -> StateProtocol {
            println("DownloadWhileOnWifi.processingIsDone")
            return self;
        }
    }
    
    // Awaiting for permission to download files over Wifi
    private class AwaitingPermissionToDownloadOverWifi : StateProtocol {
        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building AwaitingPermissionToDownloadOverWifi");
            self.stateManager = stateManager
        }
        
        func configurationChanged() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverWifi.configurationChanged");
            if stateManager.canAutomaticallyDownload {
                // It is connected to Wifi and it should start automatically
                stateManager.startAllDownloads()
                return DownloadWhileOnWifi(stateManager: stateManager)
            }
            return self;
        }
        func newTimeStamp() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverWifi.newTimeStamp");
            return self;
        }
        func wifiStateChanged() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverWifi.wifiStateChanged");
            if !stateManager.isWifiConnected {
                return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager)
            }
            return self;
        }
        
        func allowToDownload() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverWifi.allowDownload");
            stateManager.startAllDownloads()
            return DownloadOverWifiWithPermission(stateManager: stateManager);
        }
        
        func allDownloadsAreCompleted() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverWifi.allDownloadsAreCompleted");
            return self;
        }
        func processingIsDone() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverWifi.processingIsDone")
            return self;
        }
    }

    // Downloading all files under the way over the Wifi after manual permission
    private class DownloadOverWifiWithPermission : StateProtocol {
        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building DownloadOverWifiWithPermission");
            self.stateManager = stateManager
        }
        
        func configurationChanged() -> StateProtocol {
            println("DownloadOverWifiWithPermission.configurationChanged");
            return self;
        }
        func newTimeStamp() -> StateProtocol {
            println("DownloadOverWifiWithPermission.newTimeStamp");
            stateManager.stopAllDownloads()
            stateManager.startAllDownloads()
            return self;
        }
        func wifiStateChanged() -> StateProtocol {
            println("DownloadOverWifiWithPermission.wifiStateChanged");
            
            if !stateManager.isWifiConnected {
                stateManager.stopAllDownloads()
                stateManager.waitingForPermissionToDownload()
                return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager);
            }
            
            return self;
        }
        
        func allowToDownload() -> StateProtocol {
            println("DownloadOverWifiWithPermission.allowToDownload");
            return self;
        }
        
        func allDownloadsAreCompleted() -> StateProtocol {
            println("DownloadOverWifiWithPermission.allDownloadsAreCompleted");
            stateManager.startProcessing()
            return WaitingForProcessing(stateManager: stateManager);
        }
        func processingIsDone() -> StateProtocol {
            println("DownloadOverWifiWithPermission.processingIsDone")
            return self;
        }
    }
    
    // Downloading all files under the way over the cellular
    private class DownloadWhileNotOnWifi : StateProtocol {
        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building DownloadWhileNotOnWifi");
            self.stateManager = stateManager
        }
        
        func configurationChanged() -> StateProtocol {
            println("DownloadWhileNotOnWifi.configurationChanged");
            if stateManager.canAutomaticallyDownload && stateManager.canAutomaticallyDownloadViaCelullar {
                return self
            }
            
            // it is not connected to Wifi and has to have permission to continue
            stateManager.waitingForPermissionToDownload()
            return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager)
            
        }
        func newTimeStamp() -> StateProtocol {
            println("DownloadWhileNotOnWifi.newTimeStamp");
            stateManager.stopAllDownloads()
            stateManager.startAllDownloads()
            return self;
        }
        func wifiStateChanged() -> StateProtocol {
            println("DownloadWhileNotOnWifi.wifiStateChanged");
            if stateManager.isWifiConnected {
                stateManager.stopAllDownloads()
                stateManager.startAllDownloads()
                return DownloadWhileOnWifi(stateManager: stateManager)
            }
            return self;
        }
        
        func allowToDownload() -> StateProtocol {
            println("DownloadWhileNotOnWifi.allowToDownload");
            return self;
        }
        
        func allDownloadsAreCompleted() -> StateProtocol {
            println("DownloadWhileNotOnWifi.allDownloadsAreCompleted");
            stateManager.startProcessing()
            return WaitingForProcessing(stateManager: stateManager);
        }
        func processingIsDone() -> StateProtocol {
            println("DownloadOverWifiWithPermission.processingIsDone")
            return self;
        }
    }
    
    // Awaiting for permission to download files over the cellular
    private class AwaitingPermissionToDownloadOverCellular : StateProtocol {
        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building AwaitingPermissionToDownloadOverCellular")
            self.stateManager = stateManager
        }
        
        func configurationChanged() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverCellular.configurationChanged");
            if stateManager.canAutomaticallyDownloadViaCelullar {
                stateManager.startAllDownloads()
                return DownloadOverCellularWithPermission(stateManager: stateManager)
            }
            return self;
        }
        func newTimeStamp() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverCellular.newTimeStamp");
            return self;
        }
        func wifiStateChanged() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverCellular.wifiStateChanged");
            if stateManager.isWifiConnected {
                if stateManager.canAutomaticallyDownload {
                    // It is connected to Wifi and it should start automatically
                    stateManager.startAllDownloads()
                    return DownloadWhileOnWifi(stateManager: stateManager)
                } else {
                    // it is connected to Wifi but need for permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverWifi(stateManager: stateManager)
                }
            }
            
            return self
        }
        
        func allowToDownload() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverCellular.allowToDownload");
            stateManager.startAllDownloads()
            return DownloadOverCellularWithPermission(stateManager: stateManager);
        }
        
        func allDownloadsAreCompleted() -> StateProtocol {
            println("AwaitingPermissionToDownloadOverCellular.allDownloadsAreCompleted");
            return self;
        }
        
        func processingIsDone() -> StateProtocol {
            println("DownloadOverWifiWithPermission.processingIsDone")
            return self;
        }

    }
    
    // Downloading all files under the way over the Cellular after manual permission
    private class DownloadOverCellularWithPermission : StateProtocol {
        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building DownloadOverCellularWithPermission");
            self.stateManager = stateManager
        }
        
        func configurationChanged() -> StateProtocol {
            println("DownloadOverCellularWithPermission.configurationChanged");
            return self;
        }
        func newTimeStamp() -> StateProtocol {
            println("DownloadOverCellularWithPermission.newTimeStamp");
            stateManager.stopAllDownloads()
            stateManager.waitingForPermissionToDownload()
            return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager);
        }
        func wifiStateChanged() -> StateProtocol {
            println("DownloadOverCellularWithPermission.wifiStateChanged");
            if stateManager.isWifiConnected {
                stateManager.stopAllDownloads()
                stateManager.startAllDownloads()
                if stateManager.canAutomaticallyDownload {
                    // It is connected to Wifi and it should start automatically
                    return DownloadWhileOnWifi(stateManager: stateManager)
                } else {
                    // it is connected to Wifi and had permission over Cellular... assuming it is ok for Wifi a well
                    return DownloadOverWifiWithPermission(stateManager: stateManager)
                }
            }
            return self;
        }
        
        func allowToDownload() -> StateProtocol {
            println("DownloadOverCellularWithPermission.allowToDownload");
            return self;
        }
        
        func allDownloadsAreCompleted() -> StateProtocol {
            println("DownloadOverCellularWithPermission.allDownloadsAreCompleted");
            stateManager.startProcessing()
            return WaitingForProcessing(stateManager: stateManager);
        }
        func processingIsDone() -> StateProtocol {
            println("DownloadOverWifiWithPermission.processingIsDone")
            return self;
        }
  }

    // Downloading all files under the way over the Cellular after manual permission
    private class WaitingForProcessing : StateProtocol {
        private let stateManager : StateManagerProtocol
        
        init( stateManager: StateManagerProtocol ) {
            println("Building WaitingForProcessing");
            self.stateManager = stateManager
        }
        
        func configurationChanged() -> StateProtocol {
            println("WaitingForProcessing");
            return self;
        }
        func newTimeStamp() -> StateProtocol {
            println("WaitingForProcessing.newTimeStamp");
            stateManager.stopProcessing()
            if stateManager.isWifiConnected {
                if stateManager.canAutomaticallyDownload {
                    // It is connected to Wifi and it should start automatically
                    stateManager.startAllDownloads()
                    return self
                } else {
                    // it is connected to Wifi but need for permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverWifi(stateManager: stateManager)
                }
            } else {
                if stateManager.canAutomaticallyDownload && stateManager.canAutomaticallyDownloadViaCelullar {
                    // is is not connected to Wifi but it can start automatically over cellular
                    stateManager.startAllDownloads()
                    return DownloadWhileNotOnWifi(stateManager: stateManager)
                } else {
                    // it is not connected to Wifi and has to have permission to continue
                    stateManager.waitingForPermissionToDownload()
                    return AwaitingPermissionToDownloadOverCellular(stateManager: stateManager)
                }
            }
        }
        func wifiStateChanged() -> StateProtocol {
            println("WaitingForProcessing.wifiStateChanged");
            return self;
        }
        
        func allowToDownload() -> StateProtocol {
            println("WaitingForProcessing.allowToDownload");
            return self;
        }
        
        func allDownloadsAreCompleted() -> StateProtocol {
            println("WaitingForProcessing.allDownloadsAreCompleted");
            return self;
        }
        func processingIsDone() -> StateProtocol {
            println("WaitingForProcessing.processingIsDone")
            return IdleState(stateManager: stateManager);
        }
    }

    
}