//
//  ChooseSoundTableViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 8/5/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse
import MediaPlayer

class ChooseSoundTableViewController: UITableViewController, MPMediaPickerControllerDelegate {

    var user: PFUser!
    var wakeConfig: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Initialize User
        user = PFUser.currentUser()!
        
        // Initialize wakeConfig
        wakeConfig = user["wakeConfig"] as! PFObject
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var optionalCell: AnyObject? = tableView.dequeueReusableCellWithIdentifier("cell")
        var cell: UITableViewCell
        if optionalCell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        } else {
            cell = optionalCell as! UITableViewCell
        }
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Standard Alarm Sound"
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            //wakeConfig["sound"] = "alarm"
            var sound = wakeConfig["sound"] as! String?
            if sound == nil || sound! == "alarm" {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        default:
            cell.textLabel?.text = "Song from library"
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            var sound = wakeConfig["sound"] as! String?
            if sound == nil || sound! == "alarm" {
                cell.accessoryType = UITableViewCellAccessoryType.None
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.None {
            var alarmCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            var soundCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            
            // If alarm cell is checked
            if alarmCell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
                
                // Uncheck alarm cell
                alarmCell?.accessoryType = UITableViewCellAccessoryType.None
                
                // Check sound cell
                soundCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                
                // Get song
                getSong()
                
            } else {
                
                // Check alarm cell
                alarmCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                
                // Uncheck sound cell
                soundCell?.accessoryType = UITableViewCellAccessoryType.None
                
                // Set alarm
                wakeConfig["sound"] = "alarm"
                wakeConfig.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success {
                        println("IN ChooseSound FUNCTION tableView: didSelectRowAtIndexPath" + error!.localizedDescription)
                    }
                })
            }
        }
    }
    
    func getSong() {
        let picker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        picker.prompt = "Choose song"
        picker.showsCloudItems = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let mediaItem = mediaItemCollection.items[0] as! MPMediaItem
        wakeConfig["sound"] = String(mediaItem.persistentID)
        wakeConfig.saveInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                println("IN ChooseSound FUNCTION mediaPicker: didPickMediaItems" + error!.localizedDescription)
            }
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
