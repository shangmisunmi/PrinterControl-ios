//
//  DeviceListViewController.h
//  PrinterDemo
//
//  Created by mark on 2020/6/18.
//  Copyright © 2020 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunmiHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class BlueModel;

@interface DeviceListViewController : UIViewController

@property (nonatomic, assign) PrintConnectType printType;
@property (nonatomic, copy) void (^connectedStatusBlock)(BlueModel *model, PrintConnectType printConnectType);

@end

NS_ASSUME_NONNULL_END
