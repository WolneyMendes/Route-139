//
//  ToTerminal.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/15/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import UIKit

class ToTerminal: UITableViewController {

    // MARK: - Private Fields
    
    private var toTerminalStop1   : RouteStop? = nil
    private var toTerminalStop2   : RouteStop? = nil
    private var toTerminalStop3   : RouteStop? = nil
    
    private var stop1Times : Array<ScheduleEntry>? = nil
    private var stop2Times : Array<ScheduleEntry>? = nil
    private var stop3Times : Array<ScheduleEntry>? = nil

    private var refreshTimer : NSTimer? = nil
    
    // MARK: Life Cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "refreshStops:", userInfo: nil, repeats: true)
        refreshTimer?.tolerance = 10
        
        toTerminalStop1 = ModelStore.sharedInstance.toTerminalStop1
        toTerminalStop2 = ModelStore.sharedInstance.toTerminalStop2
        toTerminalStop3 = ModelStore.sharedInstance.toTerminalStop3
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
        
        if toTerminalStop1 != nil {
            count++
        }
        
        if toTerminalStop2 != nil {
            count++
        }
        
        if toTerminalStop3 != nil {
            count++
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if stop1Times != nil {
                if ModelStore.sharedInstance.numberOfScheduleRowsToShow < stop1Times!.count {
                    return ModelStore.sharedInstance.numberOfScheduleRowsToShow
                }
                return stop1Times!.count
            } else {
                return 0
            }
        case 1:
            if stop2Times != nil {
                if ModelStore.sharedInstance.numberOfScheduleRowsToShow < stop2Times!.count {
                    return ModelStore.sharedInstance.numberOfScheduleRowsToShow
                }
                return stop2Times!.count
            } else {
                return 0
            }
        case 3:
            if stop3Times != nil {
                if ModelStore.sharedInstance.numberOfScheduleRowsToShow < stop3Times!.count {
                    return ModelStore.sharedInstance.numberOfScheduleRowsToShow
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
            return toTerminalStop1!.Name
        case 1:
            return toTerminalStop2!.Name
        case 3:
            return toTerminalStop3!.Name
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("To Terminal Cell", forIndexPath: indexPath) as! UITableViewCell
    
        var scheduleEntry : ScheduleEntry? = nil
        
        // Configure the cell
        switch indexPath.section {
        case 0:
            scheduleEntry = stop1Times?[indexPath.item]
            break;
        case 1:
            scheduleEntry = stop2Times?[indexPath.item]
            break;
        case 2:
            scheduleEntry = stop3Times?[indexPath.item]
            break;
        default:
            break;
        }
        
        if scheduleEntry != nil {
            
            var extra = scheduleEntry!.NextDay ? 2400 : 0
            
            var leaving = ModelStore.timeAnalisys( NSDate(), rawTime: scheduleEntry!.stopTime.DepartureTime + extra)
            var arriving = ModelStore.timeAnalisys(NSDate(), rawTime: scheduleEntry!.terminalTime.ArrivalTime + extra)
            
            cell.textLabel?.text = " Leaving at " + leaving + " arriving at " + arriving
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
        
        var date = NSDate( timeInterval:-Double(ModelStore.sharedInstance.howFarInThePastToShowSchedule) * 60, sinceDate:NSDate() )
        
        if toTerminalStop1 != nil {
            stop1Times = ModelStore.sharedInstance.nextScheduleEntryToTerminal(toTerminalStop1!, date: date )
        }
        if toTerminalStop2 != nil {
            stop2Times = ModelStore.sharedInstance.nextScheduleEntryToTerminal(toTerminalStop2!, date: date )
        }
        if toTerminalStop3 != nil {
            stop3Times = ModelStore.sharedInstance.nextScheduleEntryToTerminal(toTerminalStop3!, date: date )
        }

        tableView.reloadData()
    }

}
