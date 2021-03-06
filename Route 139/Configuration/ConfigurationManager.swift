//
//  ConfigurationManager.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/30/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class ConfigurationManager {
    
    // MARK: Helper Objects
    struct Config {
        static let ToTerminal1        = "ToTerminal1";
        static let ToTerminal2        = "ToTerminal2";
        static let ToTerminal3        = "ToTerminal3";
        static let FromTerminal1      = "FromTerminal1";
        static let FromTerminal2      = "FromTerminal2";
        static let FromTerminal3      = "FromTerminal3";
        
        static let HowFarInThePast    = "HowFarInThePast"
        static let ScheduleRowsToShow = "NumberOfScheduleRowsToShow"
        
        static let CanAutomaticallyDownload = "CanAutomaticallyDownload"
        static let CanAutomaticallyDownloadViaCellular = "CanAutomaticallyDownloadViaCellular"
    }
    
    // MARK: Fields
    
    var toTerminalStop1: Int? = nil {
        didSet {
            if oldValue != toTerminalStop1 {
                notifyConfigurationChange()
            }
        }
    }
    
    var toTerminalStop2: Int? = nil {
        didSet {
            if oldValue != toTerminalStop2 {
                notifyConfigurationChange()
            }
        }
    }
    
    var toTerminalStop3: Int? = nil {
        didSet {
            if oldValue != toTerminalStop3 {
                notifyConfigurationChange()
            }
        }
    }
    
    
    var fromTerminalStop1 : Int? = nil {
        didSet {
            if oldValue != fromTerminalStop1 {
                notifyConfigurationChange()
            }
        }
    }

    var fromTerminalStop2 : Int? = nil {
        didSet {
            if oldValue != fromTerminalStop2 {
                notifyConfigurationChange()
            }
        }
    }
    
    var fromTerminalStop3 : Int? = nil {
        didSet {
            if oldValue != fromTerminalStop3 {
                notifyConfigurationChange()
            }
        }
    }
    
    var howFarInThePastToShowSchedule : Int = 0 {
        didSet {
            if oldValue != howFarInThePastToShowSchedule {
                notifyConfigurationChange()
            }
        }
    }
    

    var numberOfScheduleRowsToShow : Int = Int.max {
        didSet {
            if oldValue != numberOfScheduleRowsToShow {
                notifyConfigurationChange()
            }
        }
    }
    
    var canDownloadAutomatically : Bool = true {
        didSet {
            if oldValue != canDownloadAutomatically {
                notifyConfigurationChange()
            }
        }
    }
    
    var canDownloadAutomaticallyViaCellular : Bool = false {
        didSet {
            if oldValue != canDownloadAutomaticallyViaCellular {
                notifyConfigurationChange()
            }
        }
    }
    
    var modelBuilder : ModelBuilder? = nil {
        didSet {
            notifyConfigurationChange()
        }
    }
    
    
    // MARK: Private Fields
    
    private var holdNotification = false
    private var configurationIsDirty = false
    
    // MARK: Public Methods
    
    public func startConfigChangeTransaction() {
        holdNotification = true
    }
    
    public func endConfigChangeTransaction() {
        holdNotification = false
        
        if configurationIsDirty {
            configurationIsDirty = false
            notifyConfigurationChange()
        } else {
            configurationIsDirty = false
        }
    }
    
    func save() {
        
        var config = Dictionary<String,String>()
        
        println( "Saving configuration with t1=\(toTerminalStop1) and t2=\(fromTerminalStop1) and r=\(numberOfScheduleRowsToShow)" )
        
        if toTerminalStop1 != nil {
            config[ Config.ToTerminal1 ] = "\(toTerminalStop1!)"
        }
        
        if toTerminalStop2 != nil {
            config[ Config.ToTerminal2 ] = "\(toTerminalStop2!)"
        }
        
        if toTerminalStop3 != nil {
            config[ Config.ToTerminal3 ] =  "\(toTerminalStop3!)"
        }
        
        if fromTerminalStop1 != nil {
            config[ Config.FromTerminal1 ] = "\(fromTerminalStop1!)"
        }
        
        if fromTerminalStop2 != nil {
            config[ Config.FromTerminal2 ] =  "\(fromTerminalStop2!)"
        }
        
        if fromTerminalStop3 != nil {
            config[ Config.FromTerminal3 ] = "\(fromTerminalStop3!)"
        }
        
        config[ Config.HowFarInThePast ] = "\(howFarInThePastToShowSchedule)"
        config[ Config.ScheduleRowsToShow ] = "\(numberOfScheduleRowsToShow)"

        config[ Config.CanAutomaticallyDownload ] = canDownloadAutomatically ? "1" : "0"
        config[ Config.CanAutomaticallyDownloadViaCellular ] = canDownloadAutomaticallyViaCellular ? "1" : "0"

        var fileManager = NSFileManager()
        if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as?NSURL {
            let url1 = docsDir.URLByAppendingPathComponent("config.dat")
            if let path = url1.path {
                var ok = NSKeyedArchiver.archiveRootObject(config, toFile: path)
            }
            let url2 = docsDir.URLByAppendingPathComponent("db.dat")
            if let path = url2.path {
                var ok = NSKeyedArchiver.archiveRootObject(modelBuilder!, toFile: path)
            }
        }
        
    }
    
    func load() {
        
        startConfigChangeTransaction()
        
        var fileManager = NSFileManager()
        if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as?NSURL {
            let url1 = docsDir.URLByAppendingPathComponent("config.dat")
            if let path = url1.path {
                
                if fileManager.fileExistsAtPath(path) {
                    let config = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! Dictionary<String,String>
                    
                    if let stopId = config[ Config.ToTerminal1 ] {
                        toTerminalStop1 =  stopId.toInt()!
                    }
                    if let stopId = config[ Config.ToTerminal2 ] {
                        toTerminalStop2 = stopId.toInt()!
                    }
                    if let stopId = config[ Config.ToTerminal3 ] {
                        toTerminalStop3 = stopId.toInt()!
                    }
                    if let stopId = config[ Config.FromTerminal1 ] {
                        fromTerminalStop1 = stopId.toInt()!
                    }
                    if let stopId = config[ Config.FromTerminal2 ] {
                        fromTerminalStop2 = stopId.toInt()!
                    }
                    if let stopId = config[ Config.FromTerminal3 ] {
                        fromTerminalStop3 = stopId.toInt()!
                    }
                    if let howFarInThePast = config[ Config.HowFarInThePast ] {
                        howFarInThePastToShowSchedule = howFarInThePast.toInt()!
                    }
                    if let rowsToShow = config[ Config.ScheduleRowsToShow ] {
                        numberOfScheduleRowsToShow = rowsToShow.toInt()!
                    }
                    
                    if let canDownload = config[ Config.CanAutomaticallyDownload ] {
                        canDownloadAutomatically = canDownload == "1"
                    }
                    
                    if let canDownload = config[ Config.CanAutomaticallyDownloadViaCellular ] {
                        canDownloadAutomaticallyViaCellular = canDownload == "1"
                    }
                }
            }
            
            let url2 = docsDir.URLByAppendingPathComponent("db.dat")
            if let path = url2.path {
                if fileManager.fileExistsAtPath(path) {
                    var modelBuilder = (NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! ModelBuilder)

                    self.modelBuilder = modelBuilder
                }
            }
        }
        
        endConfigChangeTransaction()
        
    }
    
    // MARK: Private Methods
    
    private func notifyConfigurationChange() {
        // Notify observers.
        
        if holdNotification {
            configurationIsDirty = true
        } else {
        
            NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.Constants.RouteConfigurationChange, object: self)
            
        }
    }
    
    private func clearConfigChangeTransaction() {
        holdNotification = false
        configurationIsDirty = false
    }
    

}

