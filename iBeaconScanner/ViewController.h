//
//  ViewController.h
//  iBeaconScanner
//
//  Created by hirauchi.shinichi on 2016/05/01.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : NSViewController<CBCentralManagerDelegate,NSTableViewDelegate,NSTableViewDataSource,CLLocationManagerDelegate>

@property (nonatomic) CBCentralManager *centralManager;

@property (weak) IBOutlet NSTableView *tableView;


@end

