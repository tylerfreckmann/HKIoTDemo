//
//  AppDelegate.swift
//  HKRules
//
//  Created by Tyler Freckmann, Eric Tran on 7/29/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HKWPlayerEventHandlerDelegate {

    var window: UIWindow?
    var sleepPreventer: MMPDeepSleepPreventer!
    var alreadyReacted: Bool!
    var tracksQueue: [String]!
    var securityTimer: NSTimer!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("q0zDsAFXiBtK2FFHMwBnsqWvqsNBZcJJy3GFL9xa",
            clientKey: "YCaxY5KPgHdrGLZoUUwReGIyqEyAtAVFc0r0Mkb3")
        
        
        // Register for Push Notitications
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            println("Did register for remote notifications.")
        }
        
        // prevent from turning into background
        sleepPreventer = MMPDeepSleepPreventer()
        sleepPreventer.startPreventSleep()
        
        // Initialize alreadyReacted flag
        alreadyReacted = false
        
        // Initialize trackQueue
        tracksQueue = [String]()
        
        // Set player event handler delegate
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if !success {
                println("IN AppDelegate FUNCTION application: didRegisterForRemoteNotificationsWithDeviceToken" + error!.localizedDescription)
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println("didRecieveRemoteNotification")
        
        if !alreadyReacted {
            alreadyReacted = true
            println("Push notification received.")
            println("Notification:")
            println(userInfo)
            
            if let soundAlarm: AnyObject = userInfo["soundAlarm"] {
                // Play sound
                let soundFile = userInfo["soundFile"] as! String
                if soundFile == "alarm" {
                    let nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("alarm.wav")
                    let url = NSURL(fileURLWithPath: nsWavPath)
                    println("Played alarm sound? \(HKWControlHandler.sharedInstance().playWAV(nsWavPath))")
                } else {
                    let query = MPMediaQuery.songsQuery()
                    let predicate = MPMediaPropertyPredicate(value: soundFile, forProperty: MPMediaItemPropertyPersistentID)
                    query.addFilterPredicate(predicate)
                    
                    let item = query.items.first as! MPMediaItem
                    var assetURL = item.assetURL
                    println("Played alarm song? \(HKWControlHandler.sharedInstance().playCAF(assetURL, songName: item.title, resumeFlag: false))")
                }
                
                // Turn on lights
                let lights = userInfo["lights"] as! Bool
                if lights {
                    PFCloud.callFunctionInBackground("turnOnLights", withParameters: nil, block: { (response, error) -> Void in
                        
                    })
                }
                
                //AlarmPlayingSingleton.sharedInstance.setAlarmPlaying(true)
                println("trying to show stop alarm view controller")
                var storyBoard = UIStoryboard(name: "Main", bundle: nil)
                var stopViewController = storyBoard.instantiateViewControllerWithIdentifier("StopAlarm") as! StopAlarmViewController
                var topController = self.window?.rootViewController
                while (topController?.presentedViewController != nil) {
                    topController = topController?.presentedViewController
                }
                topController?.presentViewController(stopViewController, animated: true, completion: { () -> Void in
                    println("it worked!")
                })
            }
            
            if let alertURL: AnyObject = userInfo["showerAlertURL"] {
                // Play TTS shower alert through playStreamng
                HKWControlHandler.sharedInstance().playStreamingMedia(alertURL as! String, withCallback: { bool in
                    println(alertURL)
                    println("Playing shower TTS...")
                } )
            }
            
            if userInfo["leaveFlag"] != nil {
                // Received a notification from prepareToLeaveHouse event triggered in cloud
                // Play initial check TTS through playStreaming
                let initialCheckURL = userInfo["initialCheckURL"]! as! String
                tracksQueue.append(initialCheckURL)
                playFromQueue()
                println("Added initial leave house check TTS to queue")
                
                let finalCheckURL = userInfo["recapMessageURL"]! as! String
                tracksQueue.append(finalCheckURL)
                println("Added finalSpeech TTS to queue")
            }
            
        }
        
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func playFromQueue() {
        if !HKWControlHandler.sharedInstance().isPlaying() {
            let track = tracksQueue.removeAtIndex(0)
            if track.hasPrefix("http") {
                HKWControlHandler.sharedInstance().playStreamingMedia(track, withCallback: { (success) -> Void in
                    println("PLAY FROM QUEUE \(track)? \(success)")
                })
            } else {
                HKWControlHandler.sharedInstance().playCAF(NSURL(fileURLWithPath: track), songName: "", resumeFlag: false)
            }
        }
    }
    
    func hkwPlayEnded() {
        println("playing next song, track count: \(tracksQueue.count)")
        if tracksQueue.count != 0 {
            playFromQueue()
        } else {
            alreadyReacted = false
            //AlarmPlayingSingleton.sharedInstance.setAlarmPlaying(false)
        }
    }
    
    func appendToQueue(track: String) {
        tracksQueue.append(track)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

