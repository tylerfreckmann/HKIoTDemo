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
