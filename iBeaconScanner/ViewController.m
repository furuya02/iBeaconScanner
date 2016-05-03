//
//  ViewController.m
//  iBeaconScanner
//
//  Created by hirauchi.shinichi on 2016/05/01.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "ViewController.h"
#import "IBeacon.h"


@implementation ViewController


NSMutableArray *iBeaconsTemporary; // 計測用
NSArray *iBeacons; // 表示用

- (void)viewDidLoad {
    [super viewDidLoad];

    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    iBeacons = [NSArray array];
    iBeaconsTemporary = [NSMutableArray array];
}

-(void)update:(NSTimer*)timer{

    // スキャン停止
    [_centralManager stopScan];

    // テンポラリを表示用に(ソートして)コピーする
    iBeacons = [iBeaconsTemporary sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        IBeacon* first = a;
        IBeacon* second = b;
        if([first.uuid isEqualToString:second.uuid]){
            if(first.major == second.major){
                return first.minor - second.minor;
            }
            return first.major - second.major;
        }
        return [first.uuid compare:second.uuid];
    }];

    // 表示更新
    _tableView.reloadData;
    [iBeaconsTemporary removeAllObjects];// テンポラリデータを削除

    // スキャン開始
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
}


- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [NSTimer scheduledTimerWithTimeInterval:2.0f
                                     target:self
                                   selector:@selector(update:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{

    NSLog(@"didDiscoverPeripheral");

    NSData *data = advertisementData[@"kCBAdvDataManufacturerData"];
    if(data== nil || data.length < 25){
        return;
    }
    NSRange magicRange = NSMakeRange(0, 4);
    NSRange uuidRange = NSMakeRange(4, 16);
    NSRange majorRange = NSMakeRange(20, 2);
    NSRange minorRange = NSMakeRange(22, 2);
    NSRange powerRange = NSMakeRange(24, 1);


    Byte magicBytes[4];
    [data getBytes:&magicBytes range:magicRange];
    if(magicBytes[0]==0x4c && magicBytes[1]==0 && magicBytes[2]==0x2  && magicBytes[3]==0x15 ){
        Byte uuidBytes[16];
        [data getBytes:&uuidBytes range:uuidRange];
        NSUUID *u = [[NSUUID alloc] initWithUUIDBytes:uuidBytes];

        uint16_t majorBytes;
        [data getBytes:&majorBytes range:majorRange];
        uint16_t majorBytesBig = (majorBytes >> 8) | (majorBytes << 8);

        uint16_t minorBytes;
        [data getBytes:&minorBytes range:minorRange];
        uint16_t minorBytesBig = (minorBytes >> 8) | (minorBytes << 8);

        int8_t powerByte;
        [data getBytes:&powerByte range:powerRange];

        NSString *uuid = u.UUIDString;
        int major = majorBytesBig;
        int minor = minorBytesBig;
        int power = powerByte;

        double rssi = [RSSI doubleValue];
        NSString *name = peripheral.name;


        // テンポラリに追加する（重複は排除する）
        for ( IBeacon *iBeacon in iBeaconsTemporary){
            if ([iBeacon.uuid isEqualToString:uuid] && iBeacon.major == major && iBeacon.minor == minor) {
                iBeacon.name = name;
                iBeacon.power = power;
                iBeacon.rssi = rssi;
                return;
            }
        }
        [iBeaconsTemporary addObject:[[IBeacon new]initWith:uuid major:major minor:minor name:name power:power rssi:rssi]];
    }
}






// TableView Delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    return iBeacons.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    IBeacon *iBeacon = [iBeacons objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:@"Name"]) {
        return iBeacon.name;
    }else if ([tableColumn.identifier isEqualToString:@"UUID"]) {
        return iBeacon.uuid;
    }else if ([tableColumn.identifier isEqualToString:@"Major"]) {
        return  [NSString stringWithFormat:@"%d",iBeacon.major];
    }else if ([tableColumn.identifier isEqualToString:@"Minor"]) {
        return  [NSString stringWithFormat:@"%d",iBeacon.minor];
    }else if ([tableColumn.identifier isEqualToString:@"Power"]) {
        return  [NSString stringWithFormat:@"%ddb",iBeacon.power];
    }else if ([tableColumn.identifier isEqualToString:@"RSSI"]) {
        return  [NSString stringWithFormat:@"%.0fdb",iBeacon.rssi];
    }else if ([tableColumn.identifier isEqualToString:@"distance"]) {
        return  [NSString stringWithFormat:@"%.2fm",iBeacon.distance];
    } else {
        return  [NSString stringWithFormat:@"%@",iBeacon.proximity];
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
