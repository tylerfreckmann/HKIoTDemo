//
//  RWTItemsViewController.m
//  SuperOMNI
//
//  Created by Eric Tran on 7/2/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

#import "RWTItemsViewController.h"
#import "RWTAddItemViewController.h"
#import "RWTItem.h"
#import "ItemCell.h"
#import "HKWControlHandler.h"
#import "HKWPlayerEventHandlerSingleton.h"
#import "HKWDeviceEventHandlerSingleton.h"
#import "DataItem.h"
#import "LinearRegression.h"
#import "RegressionResult.h"

@import CoreLocation;
@import Foundation;

NSString * const kRWTStoredItemsKey = @"storedItems";

// Time to average before first playback
int const kSecondsToStart = 2;

// Amount of seconds to gather data for
int const kSecondsToPollFor = 5;

// SuperOmni and SmartThing's beacon majors
int const kSuperOmniMajor = 1010;
int const kSmartThingsMajor = 1100;

// Seonman's beacons major values
int const kEstimoteOneMinor = 60040; // super
int const kEstimoteTwoMinor = 7710;  // smart

@interface RWTItemsViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@property (strong, nonatomic) HKWControlHandler *HKWControl;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *music;
@property (strong, nonatomic) NSMutableArray *smartThingsDataPoints;
@property (strong, nonatomic) NSMutableArray *superOmniDataPoints;
@property (strong, nonatomic) LinearRegression * superLinearFit;
@property (strong, nonatomic) LinearRegression * smartLinearFit;

@property int superOmniNdx;
@property int smartThingsNdx;

@end

@implementation RWTItemsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up location manager
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    
    self.superOmniNdx = self.smartThingsNdx = -1;
    [self searchBeacons];
    
    self.HKWControl = [HKWControlHandler sharedInstance];
    [self.HKWControl setVolumeAll: 0];
    
    [self loadItems];
    
    // Init array for data points, and create instances of the linearFit calculators.
    self.superOmniDataPoints = [[NSMutableArray alloc] initWithCapacity:kSecondsToPollFor];
    self.smartThingsDataPoints = [[NSMutableArray alloc] initWithCapacity:kSecondsToPollFor];
    
    self.smartLinearFit = [LinearRegression new];
    self.superLinearFit = [LinearRegression new];
    
}

/* Goes through list of speakers and assigns index number to the superOmni and the smartThings speaker
 * If current speaker is neither, removes that speaker from playback session.
 * Currently hardcoded to look for speakers named "SuperOmni" and "SmartThings"
 */
- (void) searchBeacons {
    for (int i = 0; i < [self.HKWControl getDeviceCount]; i++) {
        DeviceInfo * dInfo = [self.HKWControl getDeviceInfoByIndex:i];
        if ([dInfo.deviceName isEqual: @"SuperOmni"])
            self.superOmniNdx = i;
        else if ([dInfo.deviceName isEqual: @"SmartThings"])
            self.smartThingsNdx = i;
        else
            [self.HKWControl removeDeviceFromSession: dInfo.deviceId];
    }
}

/* Handles the transition from current view controller to the addItemViewController */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add"]) {
        RWTAddItemViewController *addItemViewController = (RWTAddItemViewController *)navController.topViewController;
        // Callback function for when you add a new item to the list
        [addItemViewController setItemAddedCompletion:^(RWTItem *newItem) {
            [self.items addObject:newItem];
            [self.itemsTableView beginUpdates];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.items.count-1 inSection:0];
            [self.itemsTableView insertRowsAtIndexPaths:@[newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.itemsTableView endUpdates];
            [self startMonitoringItem:newItem]; // Added this line in order to start monitoring when an item is added to the list
            [self persistItems];
        }];
    }
}

/* Loads the information stored from the list */
- (void)loadItems {
    NSArray *storedItems = [[NSUserDefaults standardUserDefaults] arrayForKey:kRWTStoredItemsKey];
    self.items = [NSMutableArray array];
    
    if (storedItems) {
        for (NSData *itemData in storedItems) {
            RWTItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
            [self.items addObject:item];
            [self startMonitoringItem:item];
        }
    }
}

/* Persist takes all known items and persists them to NSUserDefaults so that user wont have to re-enter items each time app is launch (Stores the information) */
- (void)persistItems {
    NSMutableArray *itemsDataArray = [NSMutableArray array];
    for (RWTItem *item in self.items) {
        NSData *itemData = [NSKeyedArchiver archivedDataWithRootObject:item];
        [itemsDataArray addObject:itemData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:itemsDataArray forKey:kRWTStoredItemsKey];
}

/* Helper method for allocating a beaconRegion through our custom beacon 'RWTItem' */
- (CLBeaconRegion *)beaconRegionWithItem:(RWTItem *)item {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:item.uuid
                                                                           major:item.majorValue
                                                                           minor:item.minorValue
                                                                      identifier:item.name];
    return beaconRegion;
}

/* Starts ranging for iBeacons in that region for that list item. */
- (void)startMonitoringItem:(RWTItem *)item {
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:item];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

/* Turns off the ranging for an item in the list. */
- (void)stopMonitoringItem:(RWTItem *)item {
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:item];
    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}

/* Called for when a iBeacon comes within range, move out of range, or when the range of an iBeacon changes (called at a frequency of 1Hz) */
- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    // If either ndx hasn't been assign, check to see if they're available.
    if (self.superOmniNdx == -1 || self.smartThingsNdx == -1)
        [self searchBeacons];
    
    for (CLBeacon *beacon in beacons) {
        for (RWTItem *item in self.items) {
            if ([item isEqualToCLBeacon:beacon]) {
                item.lastSeenBeacon = beacon;
                
                if ([beacon.minor intValue] == kEstimoteOneMinor && self.superOmniNdx != -1) {
                    NSLog(@"IN SO");
                    [self calcAvgAndStream: beacon speakerNdx:self.superOmniNdx];
                }
                
                if ([beacon.minor intValue] == kEstimoteTwoMinor && self.smartThingsNdx != -1)
                    NSLog(@"IN ST");
                   [self calcAvgAndStream: beacon speakerNdx:self.smartThingsNdx];
            }
        }
    }
}

/* Polls for kSecondsToPollFor gathering n data points.
 * Calculates the linear regression.
 * Uses to compute the best fit rssi value to base the volume off of. */
- (void) calcAvgAndStream: (CLBeacon *) beacon
               speakerNdx: (int) index {
    int setCount;
    
    // Check if beacon is SuperOmni
    if (index == self.superOmniNdx)
        setCount = self.superOmniDataPoints.count;
    else
        setCount = self.smartThingsDataPoints.count;
    
    // Has full data set to calculate regression line
    // ... or needs more data point (from 0 to kSecondsToStart)
    if (setCount == kSecondsToPollFor)
        [self calculateRegressionLine:index currentBeacon:beacon];
    else
        [self initSpeakerPlay:beacon speakerNdx:index currentSec:setCount];
}

/* Helper method for handling when a speaker has gathered enough data points.
 * Starts calculating the linear regression line, uses that to base the volume off of */
- (void) calculateRegressionLine: (int) index
                   currentBeacon: (CLBeacon *) beacon {
    
    RegressionResult *answer;
    
    // Calculates the linear regression (best fit line with the set of data points)
    // Then clears one data to go again (allows for one second polling basically)
    if (index == self.superOmniNdx){
        answer = [self.superLinearFit calculate];
        [self.superOmniDataPoints removeObjectAtIndex:0];
        [self.superLinearFit removeFirst];
    }
    else {
        answer = [self.smartLinearFit calculate];
        [self.smartThingsDataPoints removeObjectAtIndex:0];
        [self.smartLinearFit removeFirst];
    }
    
    // Calculates the new rssi from the regression line
    float calcRSSI = (answer.slope * beacon.accuracy) + answer.intercept;
    
    // Check and use the calculated rssi value to adjust the volume of that associated speaker
    [self checkBeacon:beacon speakerNdx:index avgRSSI:calcRSSI];
    
}

/* Helper method for handling the initial speaker starting on from 0 - kSecondstoStart */
- (void) initSpeakerPlay: (CLBeacon *) beacon
              speakerNdx: (int) index
              currentSec: (int) setCount {
    
    // Add a new data point with rssi value and dist
    DataItem * temp = [DataItem new];
    temp.xValue = beacon.accuracy; // accuracy = Apple's estimation of distance to iBeacon
    temp.yValue = beacon.rssi;
    
    if (index == self.superOmniNdx) {
        [self.superOmniDataPoints addObject: temp];
        [self.superLinearFit addDataObject: temp];
        
        // Check if in range of 0 - kSecondsToStart
        [self calcInitAvg:beacon currentSec:setCount speakerNdx:index dataPointArray:self.superOmniDataPoints];
        
    } else {
        [self.smartThingsDataPoints addObject: temp];
        [self.smartLinearFit addDataObject:temp];
        
        // Check if in range of 0 - kSecondsToStart
        [self calcInitAvg:beacon currentSec:setCount speakerNdx:index dataPointArray:self.smartThingsDataPoints];
    }
}

/* Helper method for calculating the initial average rssi to use for initial speaker startup */
- (void) calcInitAvg: (CLBeacon *) beacon
          currentSec: (int) setCount
          speakerNdx: (int) index
      dataPointArray: (NSMutableArray *) data {
    
    // In the time interval of 0 to kSecondsToStart, use avg of all values up till then to start playing volume at.
    if (setCount == kSecondsToStart)
    {
        DataItem * currData;
        int sum = 0;
        for (int i = 0; i < kSecondsToStart; i++) {
            currData = data[i];
            sum += currData.xValue;
        }
        float avg = sum / data.count;
        [self checkBeacon:beacon speakerNdx:index avgRSSI:avg];
    }
}

/* Helper method for determining which speaker - beacon is interacting and acts accordingly */
- (void) checkBeacon: (CLBeacon *)beacon
          speakerNdx: (int)index
             avgRSSI: (float)rssi {
    
    // If the beacon is 'Near' or 'Immediate'(ly) close, play music on that speaker and adjust the volume if we move around.
    // if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate) {
    if ( beacon.rssi > -75) { // Our determine 'near' ranged HERE
        int volumeLvl = [self changeVolumeBasedOnRSSI:rssi];
        [self.HKWControl setVolumeDevice:[self.HKWControl getDeviceInfoByIndex:index].deviceId volume:volumeLvl];
        
        // If song isn't playing start playing it
        if (![self.HKWControl isPlaying])
            [self playStreaming];
    }
    // If beacon is 'Far' or 'Unknown' (out of reach), turn down the volume of that speaker to 0
    else// if ( beacon.proximity == CLProximityFar || beacon.proximity == CLProximityUnknown)
        [self.HKWControl setVolumeDevice:[self.HKWControl getDeviceInfoByIndex:index].deviceId volume:0];
    
}

/* Notify when user enters a monitored region through local notifcations */
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Just entered a beacon region";
    notification.soundName = @"Default";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}


/* Notify when user leaves a monitored region through local notifcations */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Just left a beacon region";
    notification.soundName = @"Default";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

/* Starts the playing of the first mp3 file embedded into project */
- (void) playStreaming {
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *filter = [NSPredicate predicateWithFormat: @"self ENDSWITH '.mp3'"];
    _music = [dirContents filteredArrayUsingPredicate:filter];
    
    NSURL *assetURL = [NSURL fileURLWithPath: [bundleRoot stringByAppendingPathComponent: _music[0]]];
    NSLog(@"NSURL: %@", assetURL);
    
    [self.HKWControl playCAF:assetURL songName:_music[0] resumeFlag:true];
}

/* Changes volume of superomni, based on calculated rssi value from best fit line.
 *
 * UPDATE: This is actually pretty unreliable. RSSI fluctuates very heavily and can be interfered with by very common things.
 * iBeacons should be used to sense just sense proximity as of right now.
 *
 * UPDATE 2: After talking with Seonman and Kevin, doing linear interpolation and averaging out a set might be what we want.
 *
 * UPDATE 3: Need to figure outhow to do something other than set ranges. Seems like there would be a better solution
 */
- (int) changeVolumeBasedOnRSSI: (float) rssi {
    
    // Realistically, can't go father than -90 approx.
    if (rssi < -75)
        return 10;
    else if (rssi < -65)
        return 15;
    else if (rssi < -50)
        return 20;
    
    return 0; // Unknown rssi
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    RWTItem *item = self.items[indexPath.row];
    cell.item = item;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Stops the monitoring of an item after removal,
        RWTItem *itemToRemove = [self.items objectAtIndex:indexPath.row];
        [self stopMonitoringItem:itemToRemove];
        
        [tableView beginUpdates];
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [self persistItems];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RWTItem *item = [self.items objectAtIndex:indexPath.row];
    NSString *detailMessage = [NSString stringWithFormat:@"UUID: %@\nMajor: %d\nMinor: %d", item.uuid.UUIDString, item.majorValue, item.minorValue];
    UIAlertView *detailAlert = [[UIAlertView alloc] initWithTitle:@"Details" message:detailMessage delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [detailAlert show];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}
@end
