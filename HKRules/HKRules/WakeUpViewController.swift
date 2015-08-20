//
//  WakeUpViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 7/30/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

class WakeUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    var user: PFUser!
    var wakeConfig: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Initialize User
        user = PFUser.currentUser()!
        
        // Initialize wakeConfig
        var optionalWakeConfig: AnyObject? = user["wakeConfig"]
        if optionalWakeConfig == nil {
            wakeConfig = PFObject(className: "WakeConfig")
            wakeConfig["sound"] = "alarm"
            wakeConfig["greeting"] = ""
            wakeConfig["weather"] = false
            wakeConfig["lights"] = false
            wakeConfig.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.user["wakeConfig"] = self.wakeConfig
                    self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if !success {
                            println("IN WakeUp FUNCTION viewDidLoad - user.save" + error!.localizedDescription)
                        }
                    })
                    self.configureTable()
                } else {
                    println("IN WakeUp FUNCTION viewDidLoad - wakeConfig.save" + error!.localizedDescription)
                }
            })
        } else {
            wakeConfig = optionalWakeConfig as! PFObject
            wakeConfig.fetchInBackgroundWithBlock({ (wakeConfig, error) -> Void in
                self.configureTable()
            })
        }
    }
    
    func configureTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var optionalCell: AnyObject? = tableView.dequeueReusableCellWithIdentifier("cell")
        var cell: UITableViewCell
        if optionalCell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        } else {
            cell = optionalCell as! UITableViewCell
        }
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Choose Alarm Sound"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        case 1:
            cell.textLabel?.text = "Customized Greeting"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        case 2:
            cell.textLabel?.text = "Weather Update"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            //wakeConfig["weather"] = true
            println("HERE")
            println(wakeConfig["weather"])
            var weather = wakeConfig["weather"] as! Bool?
            if weather == nil || !weather! {
                cell.accessoryType = UITableViewCellAccessoryType.None
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        default:
            cell.textLabel?.text = "Turn on Lights"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.accessoryType = UITableViewCellAccessoryType.None
            //wakeConfig["lights"] = false
            var lights = wakeConfig["lights"] as! Bool?
            if lights == nil || !lights! {
                cell.accessoryType = UITableViewCellAccessoryType.None
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                user.fetchInBackgroundWithBlock({ (user, error) -> Void in
                    if let user = user as! PFUser! {
                        var token: AnyObject? = user["sttoken"]
                        if token == nil {
                            self.performSegueWithIdentifier("smartThings", sender: nil)
                        }
                    }
                })
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        switch indexPath.row {
        case 0:
            self.performSegueWithIdentifier("chooseAlarmSound", sender: nil)
        case 1:
            self.performSegueWithIdentifier("customText", sender: nil)
        case 2:
            if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
                cell?.accessoryType = UITableViewCellAccessoryType.None
                wakeConfig["weather"] = false
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                wakeConfig["weather"] = true
            }
            wakeConfig.saveInBackgroundWithBlock({ (success, error) -> Void in
                if !success {
                    println("IN WakeUp FUNCTION tableView: didSelectRowAtIndexPath - case 2" + error!.localizedDescription)
                }
            })
        default:
            if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
                cell?.accessoryType = UITableViewCellAccessoryType.None
                wakeConfig["lights"] = false
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                wakeConfig["lights"] = true
                user.fetchInBackgroundWithBlock({ (user, error) -> Void in
                    if let user = user as! PFUser! {
                        var token: AnyObject? = user["sttoken"]
                        if token == nil {
                            self.performSegueWithIdentifier("smartThings", sender: nil)
                        }
                    }
                })
            }
            wakeConfig.saveInBackgroundWithBlock({ (success, error) -> Void in
                if !success {
                    println("IN WakeUp FUNCTION tableView: didSelectRowAtIndexPath - default" + error!.localizedDescription)
                }
            })
        }
    }
    
    @IBAction func setAlarm(sender: UIButton) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let dateString = dateFormatter.stringFromDate(datePicker.date)
        println(dateString)
        let u = PFUser.currentUser()?.username
        PFCloud.callFunctionInBackground("setCloudAlarm", withParameters: ["alarmTime": dateString, "username":u!]) { (response: AnyObject?, error: NSError?) -> Void in
            let test = response as? String
            println(test)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
