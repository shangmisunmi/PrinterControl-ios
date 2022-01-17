//
//  SNBluetooth.h
//  SNBle
//
//  Created by sam on 15/7/6.
//  Copyright (c) 2015年 sam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


static NSString *const SNNotiValueChange = @"SNValueChange";
/**
 *  扫描设备的回调
 *
 *  @param devices 设备数组
 */
typedef void (^scanDevicesCompleteBlock)(NSArray *devices);
/**
 *  连接设备的回调
 *
 *  @param device 设备
 *  @param err 错误信息
 */
typedef void (^connectionDeviceBlock)(CBPeripheral *device, NSError *err);

/**
 *  设备断开连接
 *
 *  @param device 设备
 *  @param err 错误信息
 */
typedef void (^disConnectionDeviceBlock)(CBPeripheral *device, NSError *err);
/**
 *  发现服务和特征的回调
 *
 *  @param serviceArray        服务数组
 *  @param characteristicArray 特征数组
 *  @param err                 错误信息
 */
typedef void (^ServiceAndCharacteristicBlock)(NSArray *serviceArray, NSArray *characteristicArray, NSError *err);



@interface SNBluetooth : NSObject <CBPeripheralDelegate, CBCentralManagerDelegate>
/**
 *  管理者
 */
@property (nonatomic, strong, readonly) CBCentralManager *manager;
/**
 *  是否蓝牙可用
 */
@property (nonatomic, assign, readonly, getter = isReady)  BOOL Ready;
/**
 *  是否连接
 */
@property (nonatomic, assign, readonly, getter = isConnection)  BOOL Connection;

/**
 *  单例
 *
 */
+ (instancetype)sharedInstance;
/**
 *  开始扫描
 *
 *  @param timeOut 扫描的超时范围
 *  @param block   回调
 */
- (void)startScanDevicesWithInterval:(NSUInteger)timeOut completeBlock:(scanDevicesCompleteBlock)block;

/**
 *  停止扫描
 */
- (void)stopScanDevices;

/**
 *  连接设备
 *
 *  @param uuid    设备uid
 *  @param timeOut 连接的超时范围
 *  @param block   回调
 */
- (void)connectionWithDeviceUUID:(NSString *)uuid timeOut:(NSUInteger)timeOut completeBlock:(connectionDeviceBlock)block;

/**
*  设备连接断开了
*  @param block   回调
*/
- (void)deviceDisConnectWithBlock:(disConnectionDeviceBlock)block;

/**
 *  断开连接
 */
- (void)disconnectionDevice;

/**
 *  扫描服务和特征
 *
 *  @param time 发现的时间范围
 *  @param block   回调
 */
- (void)discoverServiceAndCharacteristicWithInterval:(NSUInteger)time completeBlock:(ServiceAndCharacteristicBlock)block;

/**
 *  写数据到连接中的设备
 *
 *  @param sUUID 服务UUID
 *  @param cUUID 特征UUID
 *  @param data  数据
 */
- (void)writeCharacteristicWithServiceUUID:(NSString *)sUUID characteristicUUID:(NSString *)cUUID data:(NSData *)data;

/**
 *  设置通知
 *
 *  @param sUUID  服务UUID
 *  @param cUUID  特征UUID
 */
- (void)setNotificationForCharacteristicWithServiceUUID:(NSString *)sUUID characteristicUUID:(NSString *)cUUID enable:(BOOL)enable;

/**
 *  读取serviceUUid
 *
 *  @param sUUID  服务UUID
 *  @param cUUID  特征UUID
 */
- (void)readCharacteristicWithServiceUUID:(NSString *)sUUID characteristicUUID:(NSString *)cUUID;

@end
