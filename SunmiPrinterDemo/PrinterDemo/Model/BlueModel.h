//
//  BlueModel.h
//  PrinterDemo
//
//  Created by mark on 2020/6/19.
//  Copyright © 2020 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN

@interface BlueModel : NSObject

@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,strong) NSNumber *rssi;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *uuidString;

@property (nonatomic, copy) NSString *deviceIP;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *sn;

@end

NS_ASSUME_NONNULL_END
