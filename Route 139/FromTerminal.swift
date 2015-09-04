//
//  FromTerminal.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/15/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import UIKit

class FromTerminal: UITableViewController {

    // MARK: - Private Fields
    
    private var fromTerminalStop1   : RouteStop? = nil
    private var fromTerminalStop2   : RouteStop? = nil
    private var fromTerminalStop3   : RouteStop? = nil
    
    private var terminalStop : RouteStop? = nil
    
    private var stop1Times : Array<ScheduleEntry>? = nil
    private var stop2Times : Array<ScheduleEntry>? = nil
    private var stop3Times : Array<ScheduleEntry>? = nil
    
    private var refreshTimer : NSTimer? = nil
    
    // MARK: Life Cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "refreshStops:", userInfo: nil, repeats: true)
        refreshTimer?.tolerance = 10
        
        fromTerminalStop1 = AppDelegate.modelStore?.fromTerminalStop1
        fromTerminalStop2 = AppDelegate.modelStore?.fromTerminalStop2
        fromTerminalStop3 = AppDelegate.modelStore?.fromTerminalStop3
        terminalStop = AppDelegate.modelStore?.outboundTerminalStop
        refreshUI()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if refreshTimer != nil {
            refreshTimer!.invalidate()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var count = 0
        
        if fromTerminalStop1 != nil {
            count++
        }
        
        if fromTerminalStop2 != nil {
            count++
        }
        
        if fromTerminalStop3 != nil {
            count++
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if stop1Times != nil {
                if AppDelegate.configurationManager!.numberOfScheduleRowsToShow < stop1Times!.count {
                    return AppDelegate.configurationManager!.numberOfScheduleRowsToShow
                }
                return stop1Times!.count
            } else {
                return 0
            }
        case 1:
            if stop2Times != nil {
                if AppDelegate.configurationManager!.numberOfScheduleRowsToShow < stop2Times!.count {
                    return AppDelegate.configurationManager!.numberOfScheduleRowsToShow
                }
                return stop2Times!.count
            } else {
                return 0
            }
        case 3:
            if stop3Times != nil {
                if AppDelegate.configurationManager!.numberOfScheduleRowsToShow < stop3Times!.count {
                    return AppDelegate.configurationManager!.numberOfScheduleRowsToShow
                }
                return stop3Times!.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return fromTerminalStop1!.Name
        case 1:
            return fromTerminalStop2!.Name
        case 3:
            return fromTerminalStop3!.Name
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("From Terminal Cell", forIndexPath: indexPath) as! FromTerminalCell
        
        var stopTime : ScheduleEntry? = nil
        
        // Configure the cell
        switch indexPath.section {
        case 0:
            stopTime = stop1Times?[indexPath.item]
            break;
        case 1:
            stopTime = stop2Times?[indexPath.item]
            break;
        case 2:
            stopTime = stop3Times?[indexPath.item]
            break;
        default:
            break;
        }
        
        if let terminal = stopTime?.terminalTime {
            
            var now = NSDate()
            var components = ModelStore.getDateComponents(now)
            
            var extra = stopTime!.NextDay ? 2400 : 0
            var description = ""
            var gate = ""
            
            var terminalString = ModelStore.timeAnalisys( now, rawTime: terminal.DepartureTime + extra )
            var stopString = ModelStore.timeAnalisys(now, rawTime: stopTime!.stopTime.ArrivalTime + extra )
            var route = AppDelegate.modelStore!.getRoute(terminal.TripId)
            
            if stopTime!.NextDay {
                (description, gate) = ModelStore.findServiceDescription(
                    components.nextDayComponent.weekday,
                    rawTime: terminal.DepartureTime ,
                    route: route!.Name)
                
            } else {
                (description, gate) = ModelStore.findServiceDescription(
                    components.dayComponent.weekday,
                    rawTime: terminal.DepartureTime,
                    route: route!.Name)
            }
            
            var str = "Leaving at " + terminalString + " arriving at " + stopString
            cell.gate = gate

            cell.title = description
            cell.subTitle = str
            
        }
        
        return cell
    }
    
    
    // MARK: private methods
    
    private func refreshUI () {
        refreshStops()
    }
    
    func refreshStops(timer:NSTimer) {
        refreshStops()
    }
    
    private func refreshStops() {
        
        
        stop1Times = nil
        stop2Times = nil
        stop3Times = nil
        
        var date = NSDate( timeInterval:-Double(AppDelegate.configurationManager!.howFarInThePastToShowSchedule) * 60, sinceDate:NSDate() )
        
        if fromTerminalStop1 != nil {
            stop1Times = AppDelegate.modelStore!.nextScheduleEntryFromTerminal(fromTerminalStop1!, terminalStop: terminalStop!, date: date)
        }
        if fromTerminalStop2 != nil {
            stop2Times = AppDelegate.modelStore!.nextScheduleEntryFromTerminal(fromTerminalStop2!, terminalStop: terminalStop!, date: date)
        }
        if fromTerminalStop3 != nil {
            stop3Times = AppDelegate.modelStore!.nextScheduleEntryFromTerminal(fromTerminalStop3!, terminalStop: terminalStop!, date: date)
        }
        
        tableView.reloadData()
    }
    


}
