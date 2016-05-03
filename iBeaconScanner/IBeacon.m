//
//  iBeacon.m
//  iBeaconScanner
//
//  Created by hirauchi.shinichi on 2016/05/02.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "Ibeacon.h"

@implementation IBeacon

- (id)initWith:(NSString *)uuid major:(int)major minor:(int)minor name:(NSString*)name power:(int)power rssi:(double)rssi
{
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.major = major;
        self.minor = minor;
        self.name = name;
        self.power = power;
        self.rssi = rssi;


        // powerとrssiから距離を算出する
        //http://stackoverflow.com/questions/20416218/understanding-ibeacon-distancing/20434019#20434019
        // Stackoverflow - Understanding ibeacon distancing
        self.distance = -1.0;
        if(rssi != 0){
            double ratio = rssi*1.0/power;
            if (ratio < 1.0) {
                self.distance = pow(ratio,10.0);
            }else {
                self.distance =  (0.89976) * pow(ratio,7.7095) + 0.111;
            }
        }
        // 距離から「ビーコンとの距離」を定数化する
        // http://qiita.com/shu223/items/7c4e87c47eca65724305
        self.proximity = @"Unknown";
        if (_distance >= 2.0){
            self.proximity = @"Far";
        }else if(_distance >= 0.2){
            self.proximity = @"Near";
        }else if (_distance >= 0){
            self.proximity = @"Immediate";
        }
    }
    return self;
}

@end
