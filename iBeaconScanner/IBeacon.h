//
//  iBeacon.h
//  iBeaconScanner
//
//  Created by hirauchi.shinichi on 2016/05/02.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IBeacon : NSObject

@property (nonatomic) NSString *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;
@property (nonatomic) NSString *name;
@property (nonatomic) int power;
@property (nonatomic) double rssi;
@property (nonatomic) double distance;
@property (nonatomic) NSString *proximity;



- (id)initWith:(NSString *)uuid major:(int)major minor:(int)minor name:(NSString*)name power:(int)power rssi:(double)rssi;


@end

