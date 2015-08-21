//
//  ChooseScenarioViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 8/6/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

class ChooseScenarioViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        var g_alert: UIAlertController!
        
        if !HKWControlHandler.sharedInstance().isInitialized() {
            // show the network initialization dialog
            g_alert = UIAlertController(title: "Initializing", message: "If this dialog does not disappear, please check if any other HK WirelessHD App is running on the phone and kill it. Or, your phone is not in a Wifi network.", preferredStyle: .Alert)
            
            self.presentViewController(g_alert, animated: true, completion: nil)
        }
        
        if !HKWControlHandler.sharedInstance().initializing() && !HKWControlHandler.sharedInstance().isInitialized() {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if HKWControlHandler.sharedInstance().initializeHKWirelessController(kLicenseKeyGlobal, withSpeakersAdded:true) != 0 {
                    println("initializeHKWirelessControl failed : invalid license key")
                    return
                }
                println("initializeHKWirelessControl - OK");
                
                // dismiss the network initialization dialog
                if g_alert != nil {
                    g_alert.dismissViewControllerAnimated(true, completion: nil)
                }
                
            })
        }
        
//        println("trying new tts engine")
//        HKWControlHandler.sharedInstance().playStreamingMedia("http://api.voicerss.org/?key=8768e7a066a7443faa66380f7204ee96&src=HI%20%20Eric%20HELLOOO&hl=en-au", withCallback: { (success) -> Void in
//            println("success")
//        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logoutPressed(sender: UIButton) {
        PFUser.logOut()
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
