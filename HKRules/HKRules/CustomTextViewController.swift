//
//  CustomTextViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 8/5/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

class CustomTextViewController: UIViewController {
    
    @IBOutlet weak var greetingField: UITextField!
    var wakeConfig: PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        wakeConfig = PFUser.currentUser()!["wakeConfig"] as! PFObject
        greetingField.text = wakeConfig["greeting"] as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(sender: UIButton) {
        wakeConfig["greeting"] = greetingField.text
        wakeConfig.saveInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                println("IN CustomText FUNCTION save" + error!.localizedDescription)
            }
        }
//        println("trying new tts engine")
//        HKWControlHandler.sharedInstance().playStreamingMedia("http://api.voicerss.org/?key=8768e7a066a7443faa66380f7204ee96&src=%2C%2C%2CHi%20hi%2C%20let%20me%20check%20if%20the%20house%20is%20safe%20right%20now.%20%2C%2C%2Chi%2C%20All%20of%20your%20sensors%20are%20closed.%20Your%20home%20is%20safe%20and%20secured.%20%2C%2C%2CToday,%20the%20weather%20is%20Clear%2C%2C%2CThe%20current%20temperature%20is%2071degrees.%20The%20chance%20of%20it%20raining%20today%20is%200%20percent.%20%2C%2C%2CHave%20a%20good%20rest%20of%20the%20day!&hl=en-us&f=48khz_16bit_mono", withCallback: { (success) -> Void in
//            println("success")
//        })
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
