//
//  NowPlayingController.m
//  SuperOMNI
//
//  Created by Eric Tran on 7/2/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//
//  This view was made in order to mess around with the HK SDK.
//  It has no functionality with iBeacons whatsoever.
//  Also used as a means of playback control for testing iBeacon Follow Me Audio
//

#import <Foundation/Foundation.h>
#import "NowPlayingController.h"
#import "RWTItemsViewController.h"
#import "RWTAddItemViewController.h"
#import "RWTItem.h"
#import "ItemCell.h"
#import "HKWControlHandler.h"
#import "HKWPlayerEventHandlerSingleton.h"
#import "HKWDeviceEventHandlerSingleton.h"

@import MediaPlayer;
@import CoreLocation;

@interface SpeakersViewController () <UITableViewDataSource, UITableViewDelegate, HKWPlayerEventHandlerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *speakersTableView;
@property (strong, nonatomic) NSMutableArray *speakers;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *volDownBtn;
@property (weak, nonatomic) IBOutlet UIButton *volUpBtn;
@property (weak, nonatomic) IBOutlet UIButton *reverseBtn;
@property (strong, nonatomic) NSArray *music;
@property float curVolume;
@property bool firstSong;
@property bool isReverse;

@end

@implementation SpeakersViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.titleLabel setText: @"I'm Blue"];
    self.firstSong = false;
    
    [self.playBtn setSelected: [[HKWControlHandler sharedInstance] isPlaying]];
}

- (void) viewDidAppear:(BOOL)animated {
    [HKWPlayerEventHandlerSingleton sharedInstance].delegate= self;
}

/* Action method for when play button is pressed. */
- (IBAction) playPressed:(id)sender {
    // Want to pause
    if ([self.playBtn isSelected]) {
        [self.playBtn setSelected: false];
        [[HKWControlHandler sharedInstance] pause];
    }
    // Want to resume playing or start a song
    else {
        [self.playBtn setSelected: true];
        [self playStreaming: self.firstSong];
    }
}

/* Starts the playing of the first mp3 file */
- (void) playStreaming: (bool) flag{
    
    // Plays the first song that we have access too. (I'm blue.mp3)
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *filter = [NSPredicate predicateWithFormat: @"self ENDSWITH '.mp3'"];
    _music = [dirContents filteredArrayUsingPredicate:filter];
    
    NSURL *assetURL = [NSURL fileURLWithPath: [bundleRoot stringByAppendingPathComponent: _music[0]]];
    NSLog(@"NSURL: %@", assetURL);
    
    // play a song from the start
    if (flag == false)
        self.firstSong = true;
    
    [[HKWControlHandler sharedInstance] playCAF:assetURL songName:_music[0] resumeFlag:flag];
}

/* Reverse the relationship between proximity and volume */
- (IBAction)reverseDistance:(id)sender {
    self.isReverse = [self.reverseBtn isSelected];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reverse distance "
                                                    message:@"Allows inverse of distance to volume relationship. (Not implemented yet)"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

/* Backup methods for turning down volume if proximity sensors aren't working. */
- (IBAction) volumeDown: (id)sender {
    self.curVolume -= 3;
    //[[HKWControlHandler sharedInstance] setVolumeAll: self.curVolume];
    NSLog(@"Volume down: %f", self.curVolume);
}

- (IBAction) volumeUp:(id)sender {
    self.curVolume += 3;
    //[[HKWControlHandler sharedInstance] setVolumeAll: self.curVolume];
    NSLog(@"Volume up: %f", self.curVolume);
}

/* Mandatory methods from HKWireless SDK */
- (void) hkwDeviceStateUpdated:(long long)deviceId withReason:(NSInteger)reason {
    printf("In hkwDeviceStateUpdated\n");
}

- (void) hkwErrorOccurred:(NSInteger)errorCode withErrorMessage:(NSString *)errorMesg {
    printf("In hkwErrorOccured\n");
}

- (void) hkwPlayEnded {
    printf("Music play ended\n");
}
/* End mandatory methods */

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.speakers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    RWTItem *item = self.speakers[indexPath.row];
    cell.item = item;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [self.speakers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

