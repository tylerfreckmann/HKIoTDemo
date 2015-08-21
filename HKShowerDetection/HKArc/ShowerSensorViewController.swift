//
//  ViewController.swift
//  HKArc
//
//  Created by Eric Tan on 7/31/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import Parse
import Foundation
import CoreFoundation

class ShowerSensorViewController: UIViewController {

    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var resultView: UITextView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    let config = ACRCloudConfig()
    var client: ACRCloudRecognition!
    var showerStarted: Bool!
    var timeToAlert: Int!
    
    var durationTimer: NSTimer!
    var showerTimer: NSTimer!
    var startTime: NSTimeInterval!
    
    var alertCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showerStarted = false
        logoutBtn.layer.cornerRadius = 10
        stopBtn.layer.cornerRadius = 10
        resultView.layer.cornerRadius = 10
        initACRRecorder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* Callback for when logout button is pressed */
    @IBAction func logoutPressed(sender: UIButton) {
        client.stopRecordRec()
        PFUser.logOut()
    }
    
    /* Callback for when stop button is pressed */
    @IBAction func stopPressed(sender: UIButton) {
        client.stopRecordRec()
        self.durationTimer.invalidate()
        self.showerTimer.invalidate()
    }
    
    /* Initializes the ACR recorder and starts recording */
    func initACRRecorder() {
        
        config.accessKey = "754a02bc6223fc2403f260aadbe32ae8"
        config.accessSecret = "Q7TD0rS32ZRViJf1UR8JKBb4ZctoIwkx5ug148Rr"
        config.host = "ap-southeast-1.api.acrcloud.com"
        config.recMode = rec_mode_remote
        config.audioType = "recording"
        config.requestTimeout = 7
        
        config.stateBlock = {state in
            self.handleState(state)
        }
        
        config.volumeBlock = {volume in
            self.handleVolume(volume)
        }
        
        config.resultBlock = {result, resType in
            self.handleResult(result, resType: resType)
        }
        
        client = ACRCloudRecognition(config: config)
        
        // Init text in labels to be empty.
        resultView.text = ""
        successLabel.text = ""
        
        // Start recorder
        client.startRecordRec()

    }
    
    /* Callback method for handling the event when the recorder is done looping. */
    func handleResult(result: String, resType: ACRCloudResultType) {
    
        if !showerStarted {
            println("\(result)")
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.resultView.text = result
            self.parseJSON(result, showerStartedFlag: self.showerStarted)
        })
    }
    
    /* Helper method for going through the JSON and seeing if it recognize shower sound or not. */
    func parseJSON (result: String, showerStartedFlag: Bool) {
        
        // Initialize JSON parsing
        if let dataFromString = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
        
            if json["status"]["msg"] == "No result" {
                
                if !showerStartedFlag {
                    // Shower still hasn't started
                    durationLabel.text = "00:00"
                    successLabel.text = "Did you start the shower?"
                }
                else {
                    // Calculated how long shower occured for
                    var elapseTime = CACurrentMediaTime() - startTime
                    var totalElapseSeconds = Int(elapseTime)
                    
                    // Shower stopped labeled
                    successLabel.text = "You finished showering!"
                    
                    // Stop recording
                    // client.stopRecordRec()
                    
                    // Turn off duration timer
                    durationTimer.invalidate()
                    
                    // If shower was less than configured time, then stop the timer from firing
                    if totalElapseSeconds < timeToAlert {
                        println("Stopped timer from firing!")
                        showerTimer.invalidate()
                    }
                    self.showerStarted = false
                }
            }
            else if json["status"]["msg"] == "Success" {
                hearShower(json)
            }
        }
    }
    
    /* Helper function for what to do after app recoginizes shower sound for the first time */
    func hearShower (json: JSON) {
        if json["metadata"]["custom_files"][0]["audio_id"] == "shower_running" {
            
            // Set success label!
            successLabel.text = "I hear you're showering!"
            
            // Check if first time hear shower or not
            if (!showerStarted) {
                prepTimer()
            }
            else {
                println("Currently in the shower... ")
            }
        }
    }

    /* Helper method for querying for the user to get shower config data, and starting the timer */
    func prepTimer() {
        // Query for user, and then his/her shower configuration
        var username = PFUser.currentUser()?.username
        var userQuery = PFUser.query()
        userQuery!.whereKey("username", equalTo: username!)
        userQuery!.getFirstObjectInBackgroundWithBlock {
            (user: PFObject?, error: NSError?) -> Void in
            if error == nil && user != nil {
                let showerConfigID = (user!["showerConfig"] as! PFObject).objectId
                var showerQuery = PFQuery(className: "ShowerConfig")
                showerQuery.getObjectInBackgroundWithId(showerConfigID!) {
                    (config: PFObject?, error: NSError?) -> Void in
                    if error == nil && config != nil {
                        var timeTillAlert: AnyObject? = config?.objectForKey("timeTillAlert")
                        var periodicAlert: AnyObject? = config?.objectForKey("periodicAlert")
                        self.createTimer(timeTillAlert as! Int, periodicFlag: periodicAlert as! Bool)
                    }
                }
            }
        }
    }

    /* Helper function for creating and starting timer in the closure */
    func createTimer(secondsTillAlert: Int, periodicFlag: Bool) {
        showerStarted = true
        startTime = CACurrentMediaTime()
        timeToAlert = secondsTillAlert
        
        if periodicFlag {
            showerTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "triggerEventInCloud:", userInfo:periodicFlag, repeats: true)
        } else {
            showerTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(secondsTillAlert), target: self, selector: "triggerEventInCloud:", userInfo: periodicFlag, repeats: false)
        }
        durationTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateDurationTimer", userInfo: nil, repeats: true)
    }
    
    /* Called when timer has hit user shower config time
     * Triggers event in Parse Cloud to send push notifcation to HKRules application
     */
    func triggerEventInCloud(timer: NSTimer) {
        
        var username = PFUser.currentUser()?.username
        var timeString: String!
        
        if timer.userInfo as! Bool {
            // Periodic alert flag on
            //var currentTimeInMinutes = (60 * alertCount) / 60
            //var currentSecs = (60 * alertCount) % 60
            alertCount++
            var elapseTime = CACurrentMediaTime() - startTime
            var totalElapseSeconds = Int(elapseTime)
            var minutes = totalElapseSeconds / 60
            var seconds = totalElapseSeconds % 60
            
            if (minutes == 0) {
                timeString = String(seconds) + " seconds."
            }
            else if (seconds == 0) {
                timeString = String(minutes) + " minutes."
            }
            else {
                timeString = String(minutes) + " minutes and " + String(seconds) + " seconds."
            }
            
            if (timeToAlert / 30) == alertCount {
                timeString = timeString + " You have showered for your preferred maximum time.";
                showerTimer.invalidate()
            }

        }
        else {
            var minutes = timeToAlert / 60
            timeString = String(minutes) + " minutes."
        }
        
        // Trigger event in Parse Cloud to send a push notification to HKRules
        PFCloud.callFunctionInBackground("showerAlert", withParameters: ["username":username!, "showerTime":timeString!]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                println("Error with triggering event.")
            } else {
                println("Triggered event in the cloud!")
                println("Expecting push notification on HKRules app...")
            }
        }
        
    }
    
    /* Callback method for handling the change in volume */
    func handleVolume(volume: Float) {
        dispatch_async(dispatch_get_main_queue(), {
            self.volumeLabel.text = String("Volume \(volume)")
            });
    }
    
    /* Callback for handling the change in state */
    func handleState(state: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.stateLabel.text = String("State: \(state)")
        });
    }
    
    /* Helper method for updating the timer label */
    func updateDurationTimer() {
        var elapseTime = CACurrentMediaTime() - startTime
        var totalElapseSeconds = Int(elapseTime)
        var elapseMins = totalElapseSeconds / 60
        var elapseSeconds = totalElapseSeconds % 60
        
        durationLabel.text = String(format: "%02d", elapseMins) + ":" + String(format: "%02d", elapseSeconds)
    }
}

