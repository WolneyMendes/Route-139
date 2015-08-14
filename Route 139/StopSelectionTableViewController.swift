//
//  StopSelectionTableViewController.swift
//  Route139Test1
//
//  Created by Wolney Mendes on 7/22/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import UIKit

public enum StopIdentity {
    case        UnkownStop
    case   ToTerminalStop1
    case   ToTerminalStop2
    case   ToTerminalStop3
    case FromTerminalStop1
    case FromTerminalStop2
    case FromTerminalStop3
    
}

class StopSelectionTableViewController: UITableViewController {
    
    var locations : Locations? = nil
    var selectedStop : RouteStop? = nil
    var stopType = StopIdentity.UnkownStop
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        performSegueWithIdentifier("LeaveWindow", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return locations!.numberOfLocations()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedStop = locations?.locationAtIndex(indexPath.section).stopAt(indexPath.item)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let location = locations!.locationAtIndex( section )
        return location.numberOfStops
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let location = locations!.locationAtIndex( section )
        return location.location
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell
        let location = locations?.locationAtIndex(indexPath.section).stopAt(indexPath.item)
        
        cell.textLabel?.text = location!.Name
        
        if selectedStop != nil {
            if location!.Equals(selectedStop!) {
                tableView.selectRowAtIndexPath(
                    indexPath,
                    animated: true,
                    scrollPosition: UITableViewScrollPosition.None)
            }
        }
        
        return cell
    }
    

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
