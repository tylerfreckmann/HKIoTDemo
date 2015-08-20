//
//  ParseLoginVC.swift
//  HKRules
//
//  Created by Eric Tan on 8/10/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//


import Foundation
import UIKit
import Parse
import ParseUI

class ParseLoginVC: PFLogInViewController, PFSignUpViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var traits = (PFLogInFields.UsernameAndPassword
            | PFLogInFields.LogInButton
            | PFLogInFields.SignUpButton
            | PFLogInFields.PasswordForgotten
            | PFLogInFields.Facebook)
        
        // Set log in traits
        self.fields = traits
        
        // Set the logo to Harman in loginVC
        let harmanLoginLogo = UIImageView(image: UIImage(named:"Harman_Logo.png"))
        self.logInView!.logo = harmanLoginLogo
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.logInView!.logo?.frame = CGRect(x: 0, y: 0, width: 350, height: 270)
    }
}