//
//  SettingsTableViewController.swift
//  Route139Test1
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - Private Fields
    
    private var toTerminalStop1   : RouteStop? = ModelStore.sharedInstance.toTerminalStop1 {
        didSet {
            refreshUI()
        }
    }
    
    private var toTerminalStop2   : RouteStop? = ModelStore.sharedInstance.toTerminalStop2 {
        didSet {
            refreshUI()
        }
    }
    
    private var toTerminalStop3   : RouteStop? = ModelStore.sharedInstance.toTerminalStop3 {
        didSet {
            refreshUI()
        }
    }
    
    
    private var fromTerminalStop1 : RouteStop? = ModelStore.sharedInstance.fromTerminalStop1 {
        didSet {
            refreshUI()
        }
    }
    
    
    private var fromTerminalStop2 : RouteStop? = ModelStore.sharedInstance.fromTerminalStop2 {
        didSet {
            refreshUI()
        }
    }
    
    
    private var fromTerminalStop3 : RouteStop? = ModelStore.sharedInstance.fromTerminalStop3 {
        didSet {
            refreshUI()
        }
    }
    
    private var minInThePast : Int = ModelStore.sharedInstance.howFarInThePastToShowSchedule {
        didSet {
            refreshUI()
        }
    }
    
    private var numberOfScheduleRowsToShow : Int = ModelStore.sharedInstance.numberOfScheduleRowsToShow {
        didSet {
            refreshUI()
        }
    }
    
    
    // MARK: - Outlets

    @IBAction func doneStopSelection(segue: UIStoryboardSegue) {
        
        if segue.identifier == "Done" {
            if let source = segue.sourceViewController as? StopSelectionTableViewController {
                switch source.stopType {
                case .ToTerminalStop1:
                    toTerminalStop1 = source.selectedStop
                case .ToTerminalStop2:
                    toTerminalStop2 = source.selectedStop
                case .ToTerminalStop3:
                    toTerminalStop3 = source.selectedStop
                case .FromTerminalStop1:
                    fromTerminalStop1 = source.selectedStop
                case .FromTerminalStop2:
                    fromTerminalStop2 = source.selectedStop
                case .FromTerminalStop3:
                    fromTerminalStop3 = source.selectedStop
                default:break
                }
                settingsChange()
                println("Done, select is \(source.selectedStop)")
            }
        }
    }
    
    @IBAction func cancelStopSelection(segue: UIStoryboardSegue) {
        
        if segue.identifier == "Cancel" {
            if let source = segue.sourceViewController as? StopSelectionTableViewController {
                switch source.stopType {
                case .ToTerminalStop1:
                    toTerminalStop1 = toTerminalStop2
                    toTerminalStop2 = toTerminalStop3
                    toTerminalStop3 = nil
                case .ToTerminalStop2:
                    toTerminalStop2 = toTerminalStop3
                    toTerminalStop3 = nil
                case .ToTerminalStop3:
                    toTerminalStop3 = nil
                case .FromTerminalStop1:
                    fromTerminalStop1 = fromTerminalStop2
                    fromTerminalStop2 = fromTerminalStop3
                    fromTerminalStop3 = nil
                case .FromTerminalStop2:
                    fromTerminalStop2 = fromTerminalStop3
                    fromTerminalStop3 = nil
                case .FromTerminalStop3:
                    fromTerminalStop3 = nil
                default:break
                }
                
                settingsChange()
                println("Cancel")
            }
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Not sure if this is the proper place to do that.
        let howFar = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 2) ) as? StepperTableViewCell
        let howMany = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 2) ) as? StepperTableViewCell
        self.numberOfScheduleRowsToShow = howMany!.value!
        self.minInThePast = howFar!.value!
        
        settingsChange()

        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 3
        case 1 : return 3
        case 2 : return 2
        default : return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 : return "To Terminal"
        case 1 : return "From Terminal"
        case 2 : return "Scheduler Entries"
        default : return ""
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        if section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath) as! UITableViewCell
            if indexPath.item == 0 {
                cell.textLabel?.text = toTerminalStop1?.Name
            } else if indexPath.item == 1 {
                cell.textLabel?.text = toTerminalStop2?.Name
            } else {
                cell.textLabel?.text = toTerminalStop3?.Name
            }
            return cell
        } else if section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath) as! UITableViewCell
            if indexPath.item == 0 {
                cell.textLabel?.text = fromTerminalStop1?.Name
            } else if indexPath.item == 1 {
                cell.textLabel?.text = fromTerminalStop2?.Name
            } else {
                cell.textLabel?.text = fromTerminalStop3?.Name
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("StepperCell", forIndexPath: indexPath) as! StepperTableViewCell
            if indexPath.item == 0 {
                // How Far in the Past
                cell.value = ModelStore.sharedInstance.howFarInThePastToShowSchedule
                cell.values = [
                    ( 0, "From current time" ),
                    ( 5, "From 5 minutes ago" ),
                    ( 10, "From 10 minutes ago" ),
                    ( 15, "From 15 minutes ago" ),
                    ( 20, "From 20 minutes ago" ),
                    ( 25, "From 25 minutes ago" ),
                    ( 30, "From 30 minutes ago" ),
                    ( 45, "From 45 minutes ago" ),
                    ( 60, "From 1 hour ago" ),
                    ( 75, "From 1 hour and 15 minutes ago" ),
                    ( 90, "From 1 and a half hour ago" ),
                    ( 120, "From 2 hours ago" ),
                ]
            } else {
                // Number of rows
                cell.value = ModelStore.sharedInstance.numberOfScheduleRowsToShow
                cell.values = [
                    ( Int.max, "Show All Entries"),
                    ( 1, "Show One Entry" ),
                    ( 2, "Show Two Entries" ),
                    ( 3, "Show Three Entries" ),
                    ( 5, "Show Five Entries" ),
                    ( 10, "Show Ten Entries" ),
                    ( 20, "Show Twenty Entries" )
                ]
            }
            return cell
        }

    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 2 {
            return nil
        }
        return indexPath
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "StopSelection" {
            if let r = tableView.indexPathForSelectedRow() {
                let segueDestination = segue.destinationViewController as? UINavigationController
                let child = segueDestination?.childViewControllers[0] as? StopSelectionTableViewController
                if child != nil {
                    if r.section == 0 {
                        // to Terminal
                        child?.locations = ModelStore.sharedInstance.getLocationsToTerminal()
                        if r.item == 0 {
                            child?.selectedStop = toTerminalStop1
                            child?.stopType = .ToTerminalStop1
                        } else if r.item == 1 {
                            child?.selectedStop = toTerminalStop2
                            child?.stopType = .ToTerminalStop2
                        } else {
                            child?.selectedStop = toTerminalStop3
                            child?.stopType = .ToTerminalStop3
                        }
                    } else {
                        // From Terminal
                        child?.locations = ModelStore.sharedInstance.getLocationsFromTerminal()
                        if r.item == 0 {
                            child?.selectedStop = fromTerminalStop1
                            child?.stopType = .FromTerminalStop1
                        } else if r.item == 1 {
                            child?.selectedStop = fromTerminalStop2
                            child?.stopType = .FromTerminalStop2
                        } else {
                            child?.selectedStop = fromTerminalStop3
                            child?.stopType = .FromTerminalStop3
                        }
                    }
                }
            }
        }
    }

    // MARK: - Private methods

    func refreshUI() {
        if view.window != nil {

        }
        tableView.reloadData()
    }
    
    func settingsChange() {
        
        // Update Stop Values
        ModelStore.sharedInstance.toTerminalStop1 = self.toTerminalStop1
        ModelStore.sharedInstance.toTerminalStop2 = self.toTerminalStop2
        ModelStore.sharedInstance.toTerminalStop3 = self.toTerminalStop3
        ModelStore.sharedInstance.fromTerminalStop1 = self.fromTerminalStop1
        ModelStore.sharedInstance.fromTerminalStop2 = self.fromTerminalStop2
        ModelStore.sharedInstance.fromTerminalStop3 = self.fromTerminalStop3
        
        // Update other configurations
        ModelStore.sharedInstance.numberOfScheduleRowsToShow = self.numberOfScheduleRowsToShow
        ModelStore.sharedInstance.howFarInThePastToShowSchedule = self.minInThePast
        
        // Notify observers.
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.Constants.RouteConfigurationChange, object: self)
    }
    
}
