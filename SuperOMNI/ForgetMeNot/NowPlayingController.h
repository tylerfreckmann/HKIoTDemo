//
//  NowPlayingController.h
//  SuperOMNI
//
//  Created by Eric Tran on 7/2/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

#ifndef SpeakersViewController_h
#define SpeakersViewController_h


#endif

typedef void(^updateButton)(bool flag);

@interface SpeakersViewController : UITableViewController

- (IBAction) playPressed:(id)sender;
- (IBAction) volumeDown:(id)sender;
- (IBAction) volumeUp:(id)sender;
- (IBAction) reverseDistance:(id)sender; 

@end