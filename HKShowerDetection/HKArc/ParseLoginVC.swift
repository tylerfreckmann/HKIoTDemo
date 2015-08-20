//
//  ParseLoginVC.swift
//  HKShowerDetection
//
//  Created by Eric Tan on 8/17/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class ParseLoginVC: PFLogInViewController, PFSignUpViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the logo to Harman in loginVC
        let harmanLoginLogo = UIImageView(image: UIImage(named:"Harman_Logo.png"))
        self.logInView!.logo = harmanLoginLogo
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            self.performSegueWithIdentifier("goToMainVC", sender: self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.logInView!.logo?.frame = CGRect(x: 30, y: 30, width: 350, height: 270)
    }
}