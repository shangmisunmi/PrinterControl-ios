//
//  SNBluetooth.m
//  SNBle
//
//  Created by sam on 15/7/6.
//  Copyright (c) 2015年 sam. All rights reserved.
//

#import "SNBluetooth.h"
#import "SunmiHeader.h"
@interface SNBluetooth ()
@property (nonatomic, assign)  CBManagerState state;

@property (nonatomic, strong) NSMutableArray *DeviceArray;
@property (nonatomic, strong) NSMutableArray *ServiceArray;
@property (nonatomic, strong) NSMutableArray *CharacteristicArray;
@property (nonatomic, strong) CBPeripheral *ConnectionDevice;
@property (nonatomic, copy)  scanDevicesCompleteBlock scanBlock;
@property (nonatomic, copy)  connectionDeviceBlock connectionBlock;
@property (nonatomic, copy)  disConnectionDeviceBlock disConnectionBlock;
@property (nonatomic, copy)  ServiceAndCharacteristicBlock serviceAndcharBlock;
@end

@implementation SNBluetooth

#pragma mark - 自定义方法
static id _instance;
+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[self alloc] init];
	});
	return _instance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
		_ServiceArray = [[NSMutableArray alloc] init];
		_CharacteristicArray = [[NSMutableArray alloc] init];
		_DeviceArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)startScanDevicesWithInterval:(NSUInteger)timeout completeBlock:(scanDevicesCompleteBlock)block {
	[self.DeviceArray removeAllObjects];
	[self.ServiceArray removeAllObjects];
	[self.CharacteristicArray removeAllObjects];
	self.scanBlock = block;
	[self.manager scanForPeripheralsWithServices:nil options:nil];
	[self performSelector:@selector(stopScanDevices) withObject:nil afterDelay:timeout];
}

- (void)stopScanDevices {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScanDevices) object:nil];
	[self.manager stopScan];
	if (self.scanBlock) {
		self.scanBlock(self.DeviceArray);
	}
	self.scanBlock = nil;
}

- (void)connectionWithDeviceUUID:(NSString *)uuid timeOut:(NSUInteger)timeout completeBlock:(connectionDeviceBlock)block {
	self.connectionBlock = block;
	[self performSelector:@selector(connectionTimeOut) withObject:nil afterDelay:timeout];
	for (CBPeripheral *device in self.DeviceArray) {
		if ([device.identifier.UUIDString isEqualToString:uuid]) {
			[self.manager connectPeripheral:device options:nil];
			break;
		}
	}
}

- (void)deviceDisConnectWithBlock:(disConnectionDeviceBlock)block {
    self.disConnectionBlock = block;
}

- (void)disconnectionDevice {
	[self.ServiceArray removeAllObjects];
	[self.CharacteristicArray removeAllObjects];
    if (self.ConnectionDevice) {
        if (self.disConnectionBlock) {
            self.disConnectionBlock (self.ConnectionDevice, [self wrapperError:@"断开连接" Code:400]);
        }
        [self.manager cancelPeripheralConnection:self.ConnectionDevice];
    }
	self.ConnectionDevice = nil;
}

- (void)discoverServiceAndCharacteristicWithInterval:(NSUInteger)time completeBlock:(ServiceAndCharacteristicBlock)block {
    [self.ServiceArray removeAllObjects];
    [self.CharacteristicArray removeAllObjects];
	self.serviceAndcharBlock = block;
	self.ConnectionDevice.delegate = self;
	[self.ConnectionDevice discoverServices:nil];

	[self performSelector:@selector(discoverServiceAndCharacteristicWithTime) withObject:nil afterDelay:time];
}

- (void)writeCharacteristicWithServiceUUID:(NSString *)sUUID characteristicUUID:(NSString *)cUUID data:(NSData *)data {
	for (CBService *service in self.ConnectionDevice.services) {
		if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
			for (CBCharacteristic *characteristic in service.characteristics) {
				if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
					[self.ConnectionDevice writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
				}
			}
		}
	}
}

- (void)setNotificationForCharacteristicWithServiceUUID:(NSString *)sUUID characteristicUUID:(NSString *)cUUID enable:(BOOL)enable {
	for (CBService *service in self.ConnectionDevice.services) {
		if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
			for (CBCharacteristic *characteristic in service.characteristics) {
				if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
					[self.ConnectionDevice setNotifyValue:enable forCharacteristic:characteristic];
				}
			}
		}
	}
}

- (void)readCharacteristicWithServiceUUID:(NSString *)sUUID characteristicUUID:(NSString *)cUUID{
    for (CBService *service in self.ConnectionDevice.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    [self.ConnectionDevice readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}

#pragma mark - 私有方法

- (void)connectionTimeOut {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimeOut) object:nil];
	if (self.connectionBlock) {
		self.connectionBlock(nil, [self wrapperError:@"连接设备超时!" Code:400]);
	}
	self.connectionBlock = nil;
}

- (void)discoverServiceAndCharacteristicWithTime {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimeOut) object:nil];
	if (self.serviceAndcharBlock) {
		self.serviceAndcharBlock(self.ServiceArray, self.CharacteristicArray, [self wrapperError:@"发现服务和特征完成!" Code:400]);
	}
	self.connectionBlock = nil;
}

- (NSError *)wrapperError:(NSString *)msg Code:(NSInteger)code {
	NSError *error = [NSError errorWithDomain:msg code:code userInfo:nil];
	return error;
}

#pragma mark - CBCentralManagerDelegate代理方法

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	NSLog(@"当前的设备状态:%ld", (long)central.state);
	self.state = central.state;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
//	NSLog(@"发现设备:%@", peripheral);
    NSString *name = peripheral.name;
    if (name) {
        if ([[name lowercaseString] containsString:@"cloudprint_"]) {
            /*
            kkLog(@"--->name:%@  serviceL:%@  ad:%@",name, peripheral.services, advertisementData);
            NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
            if (data.length > 3) {
                Byte *testByte = (Byte *)[data bytes];
                if (testByte[2] != 0x01) { //0x01非配网下打印机 0xbb:配网下广播 0xaa:老版本
                   [self.DeviceArray addObject:peripheral];
                }
            }*/
            if (![self.DeviceArray containsObject:peripheral]) {
                [self.DeviceArray addObject:peripheral];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimeOut) object:nil];

	self.ConnectionDevice = peripheral;
	if (self.connectionBlock) {
		self.connectionBlock(peripheral, [self wrapperError:@"连接成功!" Code:401]);
	}
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];

}

- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"didDisconnectPeripheral:%@", peripheral);
    if ([self.ConnectionDevice isEqual:peripheral]) {
        if (self.disConnectionBlock) {
            self.disConnectionBlock (peripheral, [self wrapperError:@"断开连接" Code:400]);
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices:%@", peripheral.services);
	for (CBService *service in peripheral.services) {
		[self.ServiceArray addObject:service];
		[self.ConnectionDevice discoverCharacteristics:nil forService:service];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"didDiscoverCharacteristicsForService:%@", error);
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicsString]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        [self.CharacteristicArray addObject:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	if (error) {
		NSLog(@"didWriteValueForCharacteristic: %@", error);
		return;
	}
//    NSLog(@"didWriteValueForCharacteristic写入值发生改变,%@", characteristic.value);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	if (error) {
		NSLog(@"didUpdateValueForCharacteristic: %@", error);
		return;
	}
    NSString *string=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SNNotiValueChange object:characteristic.value];
	NSLog(@"didUpdateValueForCharacteristic: %@", string);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	if (error) {
		NSLog(@"didUpdateNotificationStateForCharacteristic: %@", error);
		return;
	}
    NSString *string=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
	NSLog(@"didUpdateNotificationStateForCharacteristic: %@", string);
}
#pragma mark - getter
- (BOOL)isReady {
	return self.state == CBManagerStatePoweredOn ? YES : NO;
}

- (BOOL)isConnection {
	return self.ConnectionDevice.state == CBPeripheralStateConnected ? YES : NO;
}

@end
