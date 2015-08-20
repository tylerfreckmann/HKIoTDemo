//
//  AlarmManager.swift
//  HKRules
//
//  Created by Tyler Freckmann on 8/13/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit

class AlarmPlayingSingleton {
    static let sharedInstance = AlarmPlayingSingleton()
    
    var alarmPlaying: Bool = false
    
    private init() {
        
    }
    
    func getAlarmPlaying() -> Bool {
        return self.alarmPlaying
    }
    
    func setAlarmPlaying(alarmPlaying: Bool) {
        self.alarmPlaying = alarmPlaying
    }
}
