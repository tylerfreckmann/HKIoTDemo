//
//  ItemCell.m
//  SuperOMNI
//
//  Created by Eric Tran on 7/2/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

#import "ItemCell.h"
#import "RWTItem.h"

@implementation ItemCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;
}

- (void)setItem:(RWTItem *)item {
    if (_item) {
        [_item removeObserver:self forKeyPath:@"lastSeenBeacon"];
    }
    
    _item = item;   
    [_item addObserver:self forKeyPath:@"lastSeenBeacon" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.textLabel.text = _item.name;
}

- (void)dealloc {
    [_item removeObserver:self forKeyPath:@"lastSeenBeacon"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self.item] && [keyPath isEqualToString:@"lastSeenBeacon"]) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"Location: %@ - RSII: %zd\n", [self nameForProximity:self.item.lastSeenBeacon.proximity], self.item.lastSeenBeacon.rssi];
    }
}

- (NSString *)nameForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:
            return @"Unknown";
            break;
        case CLProximityImmediate:
            return @"Immediate";
            break;
        case CLProximityNear:
            return @"Near";
            break;
        case CLProximityFar:
            return @"Far";
            break;
    }
}



@end
