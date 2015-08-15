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
    
    
    // MARK: - Outlets

    @IBOutlet weak var toTerminalStop1Row: UITableViewCell!
    @IBOutlet weak var toTerminalStop2Row: UITableViewCell!
    @IBOutlet weak var toTerminalStop3Row: UITableViewCell!
    @IBOutlet weak var fromTerminalStop1Row: UITableViewCell!
    @IBOutlet weak var fromTerminalStop2Row: UITableViewCell!
    @IBOutlet weak var fromTerminalStop3Row: UITableViewCell!
    
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
                scheduleStopSelectionChange()
                println("Done, select is \(source.selectedStop)")
            }
            
            // Remove it
            if let stop = toTerminalStop1 {
                let stops = ModelStore.sharedInstance.nextScheduleEntry(true, stop: stop, numberOfEntries: 5, now: NSDate())
                let c = stops.count
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
                
                scheduleStopSelectionChange()
                println("Cancel")
            }
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshUI()
    }
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    */

    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    */
    
    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }
    */
    
    /*
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }
    */
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToTerminalStop1" {
            let segueDestination = segue.destinationViewController as? UINavigationController
            let child = segueDestination?.childViewControllers[0] as? StopSelectionTableViewController
            if child != nil {
                child?.locations = ModelStore.sharedInstance.locationsToTerminal()
                child?.selectedStop = toTerminalStop1
                child?.stopType = .ToTerminalStop1
            }
        }
        if segue.identifier == "ToTerminalStop2" {
            let segueDestination = segue.destinationViewController as? UINavigationController
            let child = segueDestination?.childViewControllers[0] as? StopSelectionTableViewController
            if child != nil {
                child?.locations = ModelStore.sharedInstance.locationsToTerminal()
                child?.selectedStop = toTerminalStop2
                child?.stopType = .ToTerminalStop2
            }
        }
        if segue.identifier == "ToTerminalStop3" {
            let segueDestination = segue.destinationViewController as? UINavigationController
            let child = segueDestination?.childViewControllers[0] as? StopSelectionTableViewController
            if child != nil {
                child?.locations = ModelStore.sharedInstance.locationsToTerminal()
                child?.selectedStop = toTerminalStop3
                child?.stopType = .ToTerminalStop3
            }
        }
        if segue.identifier == "FromTerminalStop1" {
            let segueDestination = segue.destinationViewController as? UINavigationController
            let child = segueDestination?.childViewControllers[0] as? StopSelectionTableViewController
            if child != nil {
                child?.locations = ModelStore.sharedInstance.locationsFromTerminal()
                child?.selectedStop = fromTerminalStop1
                child?.stopType = .FromTerminalStop1
            }
        }
        if segue.identifier == "FromTerminalStop2" {
            let segueDestination = segue.destinationViewController as? UINavigationController
            let child = segueDestination?.childViewControllers[0] as? StopSelectionTableViewController
            if child != nil {
                child?.locations = ModelStore.sharedInstance.locationsToTerminal()
                child?.selectedStop = fromTerminalStop2
                child?.stopType = .FromTerminalStop2
            }
        }
        if segue.identifier == "FromTerminalStop3" {
            let segueDestination = segue.destinationViewController as? UINavigationController
            let child = segueDestination?.childViewControllers[0] as? StopSelectionTableViewController
            if child != nil {
                child?.locations = ModelStore.sharedInstance.locationsToTerminal()
                child?.selectedStop = fromTerminalStop3
                child?.stopType = .FromTerminalStop3
            }
        }
    }

    // MARK: - Private methods

    func refreshUI() {
        if view.window != nil {
            NSLog("Setting.RefreshUI")
            toTerminalStop1Row.textLabel?.text = toTerminalStop1?.Name
            toTerminalStop2Row.textLabel?.text = toTerminalStop2?.Name
            toTerminalStop3Row.textLabel?.text = toTerminalStop3?.Name
            fromTerminalStop1Row.textLabel?.text = fromTerminalStop1?.Name
            fromTerminalStop2Row.textLabel?.text = fromTerminalStop2?.Name
            fromTerminalStop3Row.textLabel?.text = fromTerminalStop3?.Name
        }
    }
    
    func scheduleStopSelectionChange() {
        
        // Update Stop Values
        ModelStore.sharedInstance.toTerminalStop1 = self.toTerminalStop1
        ModelStore.sharedInstance.toTerminalStop2 = self.toTerminalStop2
        ModelStore.sharedInstance.toTerminalStop3 = self.toTerminalStop3
        ModelStore.sharedInstance.fromTerminalStop1 = self.fromTerminalStop1
        ModelStore.sharedInstance.fromTerminalStop2 = self.fromTerminalStop2
        ModelStore.sharedInstance.fromTerminalStop3 = self.fromTerminalStop3
        
        // Notify observers.
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.Constants.StopSelectionChangeNotification, object: self)
    }
    
}
