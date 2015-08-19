//
//  ACRCloud_IOS_SDK.h
//  ACRCloud_IOS_SDK
//
//  Created by olym on 15/3/24.
//  Copyright (c) 2015年 ACRCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCloudConfig.h"

@interface ACRCloudRecognition : NSObject

-(id)initWithConfig:(ACRCloudConfig*)config;

-(void)startRecordRec;

-(void)stopRecordRec;

-(NSString*)recongize:(char*)buffer len:(int)len;

-(NSData*)get_fingerprint:(char*)pcm len:(int)len;

@end
