//
//  DeviceDiscoveryCenter.h
//  router
//
//  Created by SUNMI on 2018/8/14.
//  Copyright © 2021年 Wireless Department. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PrintStateCode 101

typedef void (^IPConnectDeviceBlock)(NSError *err);

@interface DeviceDiscoveryCenter : NSObject

+ (instancetype)sharedManager;

/**
 * 搜索设备
 *
 * @param resultBlock 回调搜索到的设备数组
 */
- (void)startSearchDeviceWithResultBlock:(void(^)(NSArray *deviceModel))resultBlock;

/**
 * 连接设备
 *
 * @param ip 当前设备 ip
 * @param completeBlock 回调结果
 */
- (void)connectSocketWithIP:(NSString *)ip completeBlock:(IPConnectDeviceBlock)completeBlock;

/**
 * 当前 IP 连接状态
 *
 */
- (BOOL)IsConnectedIPService;

/**
 * 断开已连接的 IP
 *
 */
- (void)disConnectIPService;

/**
 * 101 获取结果状态
 * 102 其他任务状态
 */
- (void)readDataFromSocketWithTag: (NSInteger)tag;

/**
 * 打印
 */
- (void)controlDevicePrintingData:(NSData *)ipData;

@end
