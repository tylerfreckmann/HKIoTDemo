//
//  RWTAddItemViewController.h
//  SuperOMNI
//
//  Created by Eric Tran on 7/2/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RWTItem;

typedef void(^RWTItemAddedCompletion)(RWTItem *newItem);
typedef void(^CheckReverseBtn) (bool flag);

@interface RWTAddItemViewController : UITableViewController

@property (nonatomic, copy) RWTItemAddedCompletion itemAddedCompletion;
@property (nonatomic, copy) CheckReverseBtn checkReverseButton;

@end

