//
//  InitialVC.swift
//  HKRules
//
//  Created by Eric Tan on 8/17/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class InitialVC: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    let loginVC = ParseLoginVC()
    let signInVC = ParseSignUpVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            self.performSegueWithIdentifier("goToScenarios", sender: self)
        }
        else {
            // Set up login traits
            loginVC.fields = (PFLogInFields.UsernameAndPassword
                | PFLogInFields.LogInButton
                | PFLogInFields.SignUpButton
                | PFLogInFields.PasswordForgotten
                | PFLogInFields.Facebook)
            
            
            // Set sign up traits
            signInVC.fields = (PFSignUpFields.UsernameAndPassword
                | PFSignUpFields.SignUpButton
                | PFSignUpFields.Email
                | PFSignUpFields.Additional
                | PFSignUpFields.DismissButton)
            
            signInVC.signUpView!.additionalField?.placeholder = "Name"
            
            loginVC.signUpController = signInVC
            loginVC.delegate = self;
            signInVC.delegate = self
            self.presentViewController(loginVC, animated: false, completion: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        self.loginVC.dismissViewControllerAnimated(true, completion: nil)
        let installation = PFInstallation.currentInstallation()
        installation["user"] = user
        installation.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if !success {
                println("IN InitialVC FUNCTION logInViewController" + error!.localizedDescription)
            }
        })
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        self.signInVC.dismissViewControllerAnimated(true, completion: nil)
        self.loginVC.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("goToScenarios", sender: self)
        let installation = PFInstallation.currentInstallation()
        installation["user"] = user
        installation.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if !success {
                println("IN InitialVC FUNCTION signUpViewController" + error!.localizedDescription)
            }
        })
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) -> Void {
        self.signInVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
